# Copyright, 2016, by Samuel G. D. Williams. <http://www.codeotaku.com>
# 
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
# 
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
# 
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.

require 'mapping/model'
require 'rainbow'

module Flopp
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
			
			def nested(*args)
				@rows << Header.new(*args)
				
				nested_rows = self.class.new(@level + 1)
				
				yield nested_rows
				
				@rows << nested_rows
			end
		end
		
		class DetailedFormatter < Mapping::Model
			def self.print(rows, output)
				self.new(rows, output).print
			end
			
			def initialize(rows, output)
				@rows = rows
				@output = output
				@width = 80
			end
			
			map(Header) do |header, rows|
				@output.puts unless header == @rows.first
				@output.puts "#{rows.indentation}#{Rainbow(header.object.command_line(header.name)).bright}"
				@output.puts "#{rows.indentation}\t#{Rainbow(header.object.description).blue}"
				@output.puts
			end
			
			map(Row) do |row, rows|
				@output.puts "#{rows.indentation}#{row.align(rows.columns)}"
			end
			
			map(Rows) do |items|
				items.collect{|row, rows| map(row, rows)}
			end
			
			def print
				map(@rows)
			end
		end
	end
end