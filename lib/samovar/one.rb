# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2016-2023, by Samuel Williams.

module Samovar
	class One
		def initialize(key, description, pattern: //, default: nil, required: false)
			@key = key
			@description = description
			@pattern = pattern
			@default = default
			@required = required
		end
		
		attr :key
		attr :description
		attr :pattern
		attr :default
		attr :required
		
		def to_s
			"<#{@key}>"
		end
		
		def to_a
			usage = [to_s, @description]
			
			if @default
				usage << "(default: #{@default.inspect})"
			elsif @required
				usage << "(required)"
			end
			
			return usage
		end
		
		def parse(input, parent = nil, default = nil)
			if input.first =~ @pattern
				input.shift
			elsif default ||= @default
				return default
			elsif @required
				raise MissingValueError.new(parent, self)
			end
		end
	end
end
