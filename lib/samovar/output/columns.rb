# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2016-2023, by Samuel Williams.

module Samovar
	module Output
		class Columns
			def initialize(rows)
				@rows = rows
				@widths = calculate_widths(rows)
			end
			
			attr :widths
			
			def calculate_widths(rows)
				widths = []
				
				rows.each do |row|
					row.each.with_index do |column, index|
						(widths[index] ||= []) << column.size
					end
				end
				
				return widths.collect(&:max)
			end
		end
	end
end
