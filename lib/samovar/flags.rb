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
	class Flags
		def initialize(text)
			@text = text
			
			@ordered = text.split(/\s+\|\s+/).map{|part| Flag.new(part)}
		end
		
		def each(&block)
			@ordered.each(&block)
		end
		
		def first
			@ordered.first
		end
		
		# Whether or not this flag should have a true/false value if not specified otherwise.
		def boolean?
			@ordered.count == 1 and @ordered.first.value.nil?
		end
		
		def count
			return @ordered.count
		end
		
		def to_s
			'[' + @ordered.join(' | ') + ']'
		end
		
		def parse(input)
			@ordered.each do |flag|
				if result = flag.parse(input)
					return result
				end
			end
			
			return nil
		end
	end
	
	class Flag
		def initialize(text)
			@text = text
			
			if text =~ /(.*?)\s(\<.*?\>)/
				@prefix = $1
				@value = $2
			else
				@prefix = @text
				@value = nil
			end
			
			*@alternatives, @prefix = @prefix.split('/')
		end
		
		attr :text
		attr :prefix
		attr :alternatives
		attr :value
		
		def to_s
			@text
		end
		
		def prefix?(token)
			@prefix == token or @alternatives.include?(token)
		end
		
		def key
			@key ||= @prefix.sub(/^-*/, '').gsub('-', '_').to_sym
		end
		
		def parse(input)
			if prefix?(input.first)
				if @value
					input.shift(2).last
				else
					input.shift; key
				end
			end
		end
	end
end
