# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2019-2023, by Samuel Williams.

require_relative 'flags'

module Samovar
	class Option
		def initialize(flags, description, key: nil, default: nil, value: nil, type: nil, required: false, multi: false, &block)
			@flags = Flags.new(flags)
			@description = description
			
			if key
				@key = key
			else
				@key = @flags.first.key
			end
			
			@default = default
			
			# If the value is given, it overrides the user specified input.
			@value = value
			@value ||= true if @flags.boolean?
			
			@type = type
			@required = required
			@block = block
			@multi = multi
		end
		
		attr :flags
		attr :description
		attr :key
		attr :default
		
		attr :value
		
		attr :type
		attr :required
		attr :block
		attr :multi
		
		def coerce_type(result)
			if @type == Integer
				Integer(result)
			elsif @type == Float
				Float(result)
			elsif @type == Symbol
				result.to_sym
			elsif @type.respond_to? :call
				@type.call(result)
			elsif @type.respond_to? :new
				@type.new(result)
			end
		end
		
		def coerce(result)
			if @type
				result = coerce_type(result)
			end
			
			if @block
				result = @block.call(result)
			end
			
			if multi
				result = Array(result)
			end
			
			return result
		end
		
		def parse(input, parent = nil, default = nil)
			if result = @flags.parse(input)
				@value.nil? ? coerce(result) : @value
			elsif default ||= @default
				return default
			elsif @required
				raise MissingValueError.new(parent, self)
			end
		end
		
		def to_s
			@flags
		end
		
		def to_a
			if @default
				[@flags, @description, "(default: #{@default})"]
			elsif @required
				[@flags, @description, "(required)"]
			else
				[@flags, @description]
			end
		end
		
		def join_results(existing_result, new_result)
			return new_result if existing_result.nil?
			return new_result unless multi
			
			existing_result + new_result
		end
	end
end
