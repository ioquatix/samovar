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

module Samovar
	class Table
		def initialize(parent = nil)
			@parent = parent
			@rows = {}
		end
		
		def each(&block)
			@rows.each_value(&block)
		end
		
		def << row
			if existing_row = @rows[row.key]
				existing_row.merge!(row)
			else
				@rows[row.key] = row
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
			@rows.each_value.collect(&:to_s).join(' ')
		end
		
		def parse(input, command)
			@rows.each do |key, row|
				next unless row.respond_to?(:parse)
				
				current = command.send(key)
				
				if result = row.parse(input, current)
					command.send("#{row.key}=", result)
				end
			end
		end
	end
end
