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

module Flopp
	module Output
		# This is an incomplete implementation of an automatic line wrapping output buffer which handles any kind of output, provided it has special wrapping markers.
		class LineWrapping
			MARKER = "\e[0;0m".freeze
			
			def initialize(output, wrapping_width = 80, minimum_width = 20)
				@output = output
				@wrapping_width = wrapping_width
				@minimum_width = minimum_width
			end
			
			ESCAPE_SEQUENCE = /(.*?)(\e\[.*?m|$)/
			
			def printable_width(text)
				text.size
			end
			
			def wrap(line)
				wrapping_offset = nil
				offset = 0
				buffer = String.new
				lines = []
				prefix = nil
				
				line.scan(ESCAPE_SEQUENCE) do |text, escape_sequence|
					width = printable_width(text)
					next_offset = offset + printable_width
					
					if next_offset > @wrapping_width
						if wrapping_offset
							text_wrap_offset = @wrapping_width - offset
							
							# This text flows past the end of the line and we have a valid wrapping offset. We need to wrap this text.
							if best_split_index = text.rindex(/\s/, text_wrap_offset) and best_split_index >= @minimum_width
								# We have enough space to wrap.
								buffer << text[0...best_split_index]
								lines << buffer
								buffer = String.new()
							else
								# In this case we can't really wrap on the current line. We fall back to letting the terminal wrap.
								return line
							end
						else
							# We don't have a specific wrapping offset, and the text flows longer than the wrapping width. We can't do anything - let the terminal wrap.
							return line
						end
					else
						buffer << text << escape_sequence
					end
					
					offset = next_offset
					
					if wrapping_offset.nil? and offset < @wrapping_width and escape_sequence == MARKER
						wrapping_offset = offset
					end
				end
			end
			
			def puts(*lines)
				lines = lines.flat_map{|line| wrap(line)}
				
				@output.puts(*lines)
			end
		end
	end
end
