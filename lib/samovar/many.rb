# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2016-2023, by Samuel Williams.

module Samovar
	# Represents multiple positional arguments in a command.
	# 
	# A `Many` parser extracts all arguments from the command line until it encounters a stop pattern (typically an option flag).
	class Many
		# Initialize a new multi-argument parser.
		# 
		# @parameter key [Symbol] The name of the attribute to store the values in.
		# @parameter description [String | Nil] A description of the arguments for help output.
		# @parameter stop [Regexp] A pattern that indicates the end of this argument list.
		# @parameter default [Object] The default value if no arguments are provided.
		# @parameter required [Boolean] Whether at least one argument is required.
		def initialize(key, description = nil, stop: /^-/, default: nil, required: false)
			@key = key
			@description = description
			@stop = stop
			@default = default
			@required = required
		end
		
		# The name of the attribute to store the values in.
		# 
		# @attribute [Symbol]
		attr :key
		
		# A description of the arguments for help output.
		# 
		# @attribute [String | Nil]
		attr :description
		
		# A pattern that indicates the end of this argument list.
		# 
		# @attribute [Regexp]
		attr :stop
		
		# The default value if no arguments are provided.
		# 
		# @attribute [Object]
		attr :default
		
		# Whether at least one argument is required.
		# 
		# @attribute [Boolean]
		attr :required
		
		# Generate a string representation for usage output.
		# 
		# @returns [String] The usage string.
		def to_s
			"<#{key}...>"
		end
		
		# Generate an array representation for usage output.
		# 
		# @returns [Array] The usage array.
		def to_a
			usage = [to_s, @description]
			
			if @default
				usage << "(default: #{@default.inspect})"
			elsif @required
				usage << "(required)"
			end
			
			return usage
		end
		
		# Parse multiple arguments from the input.
		# 
		# @parameter input [Array(String)] The command-line arguments.
		# @parameter parent [Command | Nil] The parent command.
		# @parameter default [Object | Nil] An override for the default value.
		# @returns [Array(String) | Object | Nil] The parsed values, or the default if none match.
		def parse(input, parent = nil, default = nil)
			if @stop and stop_index = input.index{|item| @stop === item}
				input.shift(stop_index)
			elsif input.any?
				input.shift(input.size)
			elsif default ||= @default
				return default
			elsif @required
				raise MissingValueError.new(parent, @key)
			end
		end
	end
end
