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
	class Many
		def initialize(key, description = nil, stop: /^-/, default: nil, required: false)
			@key = key
			@description = description
			@stop = stop
			@default = default
			@required = required
		end
		
		attr :key
		attr :description
		attr :stop
		attr :default
		attr :required
		
		def to_s
			"<#{key}...>"
		end
		
		def to_a
			usage = [to_s, @description]
			
			if @default
				usage << "(default: #{@default.inspect})"
			elsif @required
				usage << "(required)"
			end
			
			return usage
		end
		
		def parse(input, parent = nil, default = nil)
			if @stop and stop_index = input.index{|item| @stop === item}
				input.shift(stop_index)
			elsif input.any?
				input.shift(input.size)
			elsif default ||= @default
				return default
			elsif @required
				raise MissingValueError.new(parent, self)
			end
		end
	end
end
