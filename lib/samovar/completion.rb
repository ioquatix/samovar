# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2026, by Samuel Williams.

module Samovar
	# Shell completion support for Samovar commands.
	module Completion
		# A single completion candidate.
		Suggestion = Struct.new(:value, :description, :type, keyword_init: true) do
			def to_s
				value.to_s
			end
		end
		
		# The result of a completion request.
		class Result
			include Enumerable
			
			def initialize(suggestions = [])
				@suggestions = suggestions
			end
			
			attr :suggestions
			
			def each(&block)
				@suggestions.each(&block)
			end
			
			def empty?
				@suggestions.empty?
			end
			
			def +(other)
				self.class.new(@suggestions + other.suggestions)
			end
		end
		
		# The context provided to dynamic completion callbacks.
		Context = Struct.new(:command_class, :argv, :index, :current, :row, :option, :environment, keyword_init: true)
		
		# Complete the command line for the given command class.
		# 
		# @parameter command_class [Class] The command class to complete.
		# @parameter argv [Array(String)] The application arguments.
		# @parameter index [Integer] The zero-based application argument cursor index.
		# @parameter environment [Hash] The environment for completion callbacks.
		# @returns [Result] The completion result.
		def self.complete(command_class, argv, index:, environment: ENV)
			argv = argv.collect(&:to_s)
			index = Integer(index)
			
			if index < 0 || index > argv.size
				raise ArgumentError, "Completion index out of range: #{index}"
			end
			
			current = index < argv.size ? argv[index] : ""
			words = argv.take(index)
			
			context = Context.new(
				command_class: command_class,
				argv: argv,
				index: index,
				current: current,
				environment: environment,
			)
			
			complete_command(command_class, words, context)
		end
		
		# Print the completion result in a stable TSV format.
		# 
		# @parameter result [Result] The result to print.
		# @parameter output [IO] The output stream.
		def self.print(result, output = $stdout)
			result.each do |suggestion|
				output.puts [
					escape(suggestion.value),
					escape(suggestion.description),
					escape(suggestion.type),
				].join("\t")
			end
		end
		
		# Generate a shell completion script for an executable.
		# 
		# @parameter shell [String | Symbol] The shell name: bash, zsh, or fish.
		# @parameter executable [String] The executable name.
		# @returns [String] The shell completion script.
		def self.script(shell:, executable:)
			case shell.to_sym
			when :bash
				bash_script(executable)
			when :zsh
				zsh_script(executable)
			when :fish
				fish_script(executable)
			else
				raise ArgumentError, "Unsupported shell: #{shell.inspect}"
			end
		end
		
		def self.complete_command(command_class, words, context)
			complete_rows(command_class, command_class.table.merged, words.dup, context)
		end
		
		def self.complete_rows(command_class, table, input, context)
			collected = []
			
			table.each do |row|
				case row
				when Options
					result = consume_options(row, input, context)
					return result if result
					
					if input.empty?
						flags = option_suggestions(row, context.current)
						
						if context.current.start_with?("-") && flags.any?
							return Result.new(flags)
						elsif context.current.empty?
							collected.concat(flags)
						end
					end
				when Nested
					if input.empty?
						result = nested_suggestions(row, context)
						
						if result.empty? && context.current.start_with?("-") && row.default
							return Result.new(collected) + complete_command(row.commands.fetch(row.default), [], context)
						end
						
						return Result.new(collected) + result
					elsif command_class = row.commands[input.first]
						input.shift
						return complete_command(command_class, input, context)
					else
						return Result.new(collected)
					end
				when One
					if input.empty?
						return Result.new(collected) + provider_suggestions(row.completions, context, row: row)
					elsif row.pattern =~ input.first
						input.shift
					else
						return Result.new(collected)
					end
				when Many
					if row.stop
						input.shift while input.any? && !(row.stop === input.first)
						
						next if row.stop === context.current
					else
						input.clear
					end
					
					if input.empty?
						return Result.new(collected) + provider_suggestions(row.completions, context, row: row)
					end
				when Split
					if offset = input.index(row.marker)
						input.shift(offset + 1)
						return Result.new(collected) + provider_suggestions(row.completions, context, row: row)
					elsif input.empty?
						suggestions = []
						
						if row.marker.start_with?(context.current)
							suggestions << Suggestion.new(value: row.marker, description: row.description, type: :split)
						end
						
						return Result.new(collected + suggestions)
					else
						return Result.new(collected)
					end
				end
			end
			
			Result.new(collected)
		end
		
		def self.consume_options(options, input, context)
			while token = input.first
				option = options.option_for(token)
				break unless option
				
				flag = option.flag_for(token)
				input.shift
				
				if flag && !flag.boolean?
					if input.any?
						input.shift
					else
						return provider_suggestions(option.completions, context, row: options, option: option)
					end
				end
			end
			
			nil
		end
		
		def self.option_suggestions(options, prefix)
			options.flat_map do |option|
				option.flags.completions.collect do |value|
					next unless value.start_with?(prefix)
					
					Suggestion.new(value: value, description: option.description, type: :option)
				end
			end.compact
		end
		
		def self.nested_suggestions(nested, context)
			suggestions = nested.commands.collect do |name, command_class|
				next unless name.start_with?(context.current)
				
				Suggestion.new(value: name, description: command_class.description, type: :command)
			end.compact
			
			Result.new(suggestions)
		end
		
		def self.provider_suggestions(provider, context, row:, option: nil)
			return Result.new unless provider
			
			context = context.dup
			context.row = row
			context.option = option
			
			values = provider.respond_to?(:call) ? provider.call(context) : provider
			
			Result.new(Array(values).filter_map do |value|
				suggestion = wrap_suggestion(value)
				
				suggestion if suggestion.value.to_s.start_with?(context.current)
			end)
		end
		
		def self.wrap_suggestion(value)
			case value
			when Suggestion
				value
			when Hash
				Suggestion.new(**value)
			else
				Suggestion.new(value: value)
			end
		end
		
		def self.escape(value)
			value.to_s.gsub(/[\t\r\n]/, " ")
		end
		
		def self.function_name(executable)
			"_#{executable.gsub(/[^a-zA-Z0-9_]/, "_")}_completion"
		end
		
		def self.bash_script(executable)
			function = function_name(executable)
			
			<<~SCRIPT
				#{function}() {
					local index=$((COMP_CWORD - 1))
					local argv=("${COMP_WORDS[@]:1}")
					COMPREPLY=()

					while IFS=$'\\t' read -r value description type; do
						COMPREPLY+=("$value")
					done < <(SAMOVAR_COMPLETE="$index" #{executable} "${argv[@]}")
				}

				complete -F #{function} #{executable}
			SCRIPT
		end
		
		def self.zsh_script(executable)
			function = function_name(executable)
			
			<<~SCRIPT
				#compdef #{executable}

				#{function}() {
					local index=$((CURRENT - 2))
					local -a argv
					argv=("${words[@]:1}")

					local -a completions
					while IFS=$'\\t' read -r value description type; do
						completions+=("${value}:${description}")
					done < <(SAMOVAR_COMPLETE="$index" #{executable} "${argv[@]}")

					_describe '#{executable}' completions
				}

				#{function}
			SCRIPT
		end
		
		def self.fish_script(executable)
			<<~SCRIPT
				function __#{function_name(executable)} --description 'Complete #{executable}'
					set -l argv (commandline -opc)
					set -e argv[1]
					set -l index (math (count $argv) - 1)

					SAMOVAR_COMPLETE="$index" #{executable} $argv | while read -l line
						echo $line
					end
				end

				complete -c #{executable} -f -a "(__#{function_name(executable)})"
			SCRIPT
		end
	end
end
