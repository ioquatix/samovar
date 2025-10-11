# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2019-2025, by Samuel Williams.

module Samovar
	module Output
		# Represents a row in usage output.
		# 
		# Rows display formatted option or argument information with proper column alignment.
		class Row < Array
			# Initialize a new row.
			# 
			# @parameter object [Object] The object to convert to a row (must respond to `to_a`).
			def initialize(object)
				@object = object
				super object.to_a.collect(&:to_s)
			end
			
			# The source object for this row.
			# 
			# @attribute [Object]
			attr :object
			
			# Generate an aligned row string.
			# 
			# @parameter columns [Columns] The columns for alignment.
			# @returns [String] The aligned row string.
			def align(columns)
				self.collect.with_index do |value, index|
					value.ljust(columns.widths[index])
				end.join("  ")
			end
		end
	end
end
