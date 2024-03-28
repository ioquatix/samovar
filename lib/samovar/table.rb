# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2016-2023, by Samuel Williams.

module Samovar
	class Table
		def self.nested(klass, parent = nil)
			if klass.superclass.respond_to?(:table)
				parent = klass.superclass.table
			end
			
			self.new(parent, name: klass.name)
		end
		
		def initialize(parent = nil, name: nil)
			@parent = parent
			@name = name
			@rows = {}
		end
		
		def freeze
			return self if frozen?
			
			@rows.freeze
			
			super
		end
		
		def [] key
			@rows[key]
		end
		
		def each(&block)
			@rows.each_value(&block)
		end
		
		def << row
			if existing_row = @rows[row.key] and existing_row.respond_to?(:merge!)
				existing_row.merge!(row)
			else
				# In the above case where there is an existing row, but it doensn't support being merged, we overwrite it. This preserves order.
				@rows[row.key] = row.dup
			end
		end
		
		def empty?
			@rows.empty? && @parent&.empty?
		end
		
		def merge_into(table)
			@parent&.merge_into(table)
			
			@rows.each_value do |row|
				table << row
			end
			
			return table
		end
		
		def merged
			if @parent.nil? or @parent.empty?
				return self
			else
				merge_into(self.class.new)
			end
		end
		
		def usage
			@rows.each_value.collect(&:to_s).reject(&:empty?).join(' ')
		end
		
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
