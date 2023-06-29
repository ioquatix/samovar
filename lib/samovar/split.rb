# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2016-2023, by Samuel Williams.

module Samovar
	class Split
		def initialize(key, description, marker: '--', default: nil, required: false)
			@key = key
			@description = description
			@marker = marker
			@default = default
			@required = required
		end
		
		attr :key
		attr :description
		attr :marker
		attr :default
		attr :required
		
		def to_s
			"#{@marker} <#{@key}...>"
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
			if offset = input.index(@marker)
				input.pop(input.size - offset).tap(&:shift)
			elsif default ||= @default
				return default
			elsif @required
				raise MissingValueError.new(parent, self)
			end
		end
	end
end
