# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2016-2023, by Samuel Williams.

module Samovar
	class Many
		def initialize(key, description = nil, stop: /^-/, default: nil, required: false)
			@key = key
			@description = description
			@stop = stop
			@default = default
			@required = required
		end
		
		attr :key
		attr :description
		attr :stop
		attr :default
		attr :required
		
		def to_s
			"<#{key}...>"
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
			if @stop and stop_index = input.index{|item| @stop === item}
				input.shift(stop_index)
			elsif input.any?
				input.shift(input.size)
			elsif default ||= @default
				return default
			elsif @required
				raise MissingValueError.new(parent, self)
			end
		end
	end
end
