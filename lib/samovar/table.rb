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
				
				if result = row.parse(input, parent, current)
					parent.send("#{row.key}=", result)
				end
			end
		end
	end
end
