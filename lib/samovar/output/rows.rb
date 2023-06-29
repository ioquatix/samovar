# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2019-2023, by Samuel Williams.

require_relative 'header'
require_relative 'columns'
require_relative 'row'

module Samovar
	module Output
		class Rows
			include Enumerable
			
			def initialize(level = 0)
				@level = level
				@rows = []
			end
			
			attr :level
			
			def empty?
				@rows.empty?
			end
			
			def first
				@rows.first
			end
			
			def last
				@rows.last
			end
			
			def indentation
				@indentation ||= "\t" * @level
			end
			
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
			
			def << object
				@rows << Row.new(object)
				
				return self
			end
			
			def columns
				@columns ||= Columns.new(@rows.select{|row| row.is_a? Array})
			end
			
			def nested(*arguments)
				@rows << Header.new(*arguments)
				
				nested_rows = self.class.new(@level + 1)
				
				yield nested_rows
				
				@rows << nested_rows
			end
		end
	end
end
