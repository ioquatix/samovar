# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2016-2025, by Samuel Williams.

module Samovar
	# Represents a table of parsing rows for a command.
	# 
	# A table manages the collection of options, arguments, and nested commands that define how to parse a command line.
	class Table
		# Create a nested table that inherits from the parent class's table.
		# 
		# @parameter klass [Class] The command class to create a table for.
		# @parameter parent [Table | Nil] The parent table to inherit from.
		# @returns [Table] The new table.
		def self.nested(klass, parent = nil)
			if klass.superclass.respond_to?(:table)
				parent = klass.superclass.table
			end
			
			self.new(parent, name: klass.name)
		end
		
		# Initialize a new table.
		# 
		# @parameter parent [Table | Nil] The parent table to inherit from.
		# @parameter name [String | Nil] The name of the command this table belongs to.
		def initialize(parent = nil, name: nil)
			@parent = parent
			@name = name
			@rows = {}
		end
		
		# Freeze this table.
		# 
		# @returns [Table] The frozen table.
		def freeze
			return self if frozen?
			
			@rows.freeze
			
			super
		end
		
		# Get a row by key.
		# 
		# @parameter key [Symbol] The key to look up.
		# @returns [Object | Nil] The row with the given key.
		def [] key
			@rows[key]
		end
		
		# Iterate over each row.
		# 
		# @yields {|row| ...} Each row in the table.
		def each(&block)
			@rows.each_value(&block)
		end
		
		# Add a row to the table.
		# 
		# @parameter row The row to add.
		def << row
			if existing_row = @rows[row.key] and existing_row.respond_to?(:merge!)
				existing_row.merge!(row)
			else
				# In the above case where there is an existing row, but it doensn't support being merged, we overwrite it. This preserves order.
				@rows[row.key] = row.dup
			end
		end
		
		# Check if this table is empty.
		# 
		# @returns [Boolean] True if this table and its parent are empty.
		def empty?
			@rows.empty? && @parent&.empty?
		end
		
		# Merge this table's rows into another table.
		# 
		# @parameter table [Table] The table to merge into.
		# @returns [Table] The merged table.
		def merge_into(table)
			@parent&.merge_into(table)
			
			@rows.each_value do |row|
				table << row
			end
			
			return table
		end
		
		# Get a merged table that includes parent rows.
		# 
		# @returns [Table] The merged table.
		def merged
			if @parent.nil? or @parent.empty?
				return self
			else
				merge_into(self.class.new)
			end
		end
		
		# Generate a usage string from all rows.
		# 
		# @returns [String] The usage string.
		def usage
			@rows.each_value.collect(&:to_s).reject(&:empty?).join(" ")
		end
		
		# Parse the input according to the rows in this table.
		# 
		# @parameter input [Array(String)] The command-line arguments.
		# @parameter parent [Command] The parent command to store results in.
		def parse(input, parent)
			@rows.each do |key, row|
				next unless row.respond_to?(:parse)
				
				current = parent.send(key)
				
				result = row.parse(input, parent, current)
				if result != nil
					parent.public_send("#{row.key}=", result)
				end
			end
		end
	end
end
