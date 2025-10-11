# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2019-2025, by Samuel Williams.

require_relative "header"
require_relative "columns"
require_relative "row"

module Samovar
	module Output
		# Represents a collection of rows for usage output.
		# 
		# Manages hierarchical usage information with support for nesting and formatting.
		class Rows
			include Enumerable
			
			# Initialize a new rows collection.
			# 
			# @parameter level [Integer] The indentation level for this collection.
			def initialize(level = 0)
				@level = level
				@rows = []
			end
			
			# The indentation level.
			# 
			# @attribute [Integer]
			attr :level
			
			# Check if this collection is empty.
			# 
			# @returns [Boolean] True if there are no rows.
			def empty?
				@rows.empty?
			end
			
			# Get the first row.
			# 
			# @returns [Object | Nil] The first row.
			def first
				@rows.first
			end
			
			# Get the last row.
			# 
			# @returns [Object | Nil] The last row.
			def last
				@rows.last
			end
			
			# Get the indentation string for this level.
			# 
			# @returns [String] The indentation string.
			def indentation
				@indentation ||= "\t" * @level
			end
			
			# Iterate over each row.
			# 
			# @parameter ignore_nested [Boolean] Whether to skip nested rows.
			# @yields {|row, rows| ...} Each row with its parent collection.
			def each(ignore_nested: false, &block)
				return to_enum(:each, ignore_nested: ignore_nested) unless block_given?
				
				@rows.each do |row|
					if row.is_a?(self.class)
						row.each(&block) unless ignore_nested
					else
						yield row, self
					end
				end
			end
			
			# Add a row to this collection.
			# 
			# @parameter object [Object] The object to add as a row.
			# @returns [Rows] Self.
			def << object
				@rows << Row.new(object)
				
				return self
			end
			
			# Get the columns for alignment.
			# 
			# @returns [Columns] The columns calculator.
			def columns
				@columns ||= Columns.new(@rows.select{|row| row.is_a? Array})
			end
			
			# Create a nested section in the output.
			# 
			# @parameter arguments [Array] Arguments for the header.
			# @yields {|rows| ...} A block that populates the nested rows.
			def nested(*arguments)
				@rows << Header.new(*arguments)
				
				nested_rows = self.class.new(@level + 1)
				
				yield nested_rows
				
				@rows << nested_rows
			end
		end
	end
end
