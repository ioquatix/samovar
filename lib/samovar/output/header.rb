# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2019-2023, by Samuel Williams.

module Samovar
	module Output
		class Header
			def initialize(name, object)
				@name = name
				@object = object
			end
			
			attr :name
			attr :object
			
			def align(columns)
				@object.command_line(@name)
			end
		end
	end
end
