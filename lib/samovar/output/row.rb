# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2019-2023, by Samuel Williams.

module Samovar
	module Output
		class Row < Array
			def initialize(object)
				@object = object
				super object.to_a.collect(&:to_s)
			end
			
			attr :object
			
			def align(columns)
				self.collect.with_index do |value, index|
					value.ljust(columns.widths[index])
				end.join('  ')
			end
		end
	end
end
