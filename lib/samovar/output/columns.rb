# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2016-2023, by Samuel Williams.

module Samovar
	# Namespace for output formatting classes.
	module Output
	end
end

module Samovar
	module Output
		# Represents column widths for aligned output formatting.
		# 
		# Calculates the maximum width of each column across all rows for proper text alignment.
		class Columns
			# Initialize column width calculator.
			# 
			# @parameter rows [Array(Array)] The rows to calculate column widths from.
			def initialize(rows)
				@rows = rows
				@widths = calculate_widths(rows)
			end
			
			# The calculated column widths.
			# 
			# @attribute [Array(Integer)]
			attr :widths
			
			# Calculate the maximum width for each column.
			# 
			# @parameter rows [Array(Array)] The rows to analyze.
			# @returns [Array(Integer)] The maximum width of each column.
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
