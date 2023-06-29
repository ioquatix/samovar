# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2016-2023, by Samuel Williams.

module Samovar
	class Nested
		def initialize(key, commands, default: nil, required: false)
			@key = key
			@commands = commands
			
			# This is the default name [of a command], not the default command:
			@default = default
			
			@required = required
		end
		
		attr :key
		attr :commands
		attr :default
		attr :required
		
		def to_s
			"<#{@key}>"
		end
		
		def to_a
			usage = [self.to_s]
			
			if @commands.size == 0
				usage << "No commands available."
			elsif @commands.size == 1
				usage << "Only #{@commands.first}."
			else
				usage << "One of: #{@commands.keys.join(', ')}."
			end
			
			if @default
				usage << "(default: #{@default})"
			elsif @required
				usage << "(required)"
			end
			
			return usage
		end
		
		# @param default [Command] the default command if any.
		def parse(input, parent = nil, default = nil)
			if command = @commands[input.first]
				name = input.shift
				
				# puts "Instantiating #{command} with #{input}"
				command.new(input, name: name, parent: parent)
			elsif default
				return default
			elsif @default
				@commands[@default].new(input, name: @default, parent: parent)
			elsif @required
				raise MissingValueError.new(parent, self)
			end
		end
		
		def usage(rows)
			rows << self
			
			@commands.each do |key, klass|
				klass.usage(rows, key)
			end
		end
	end
end
