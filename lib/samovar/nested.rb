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
	class Nested
		def initialize(key, commands, default: nil, required: false)
			@key = key
			@commands = commands
			
			# This is the default name [of a command], not the default command:
			@default = default
			
			@required = required
		end
		
		attr :key
		attr :commands
		attr :default
		attr :required
		
		def to_s
			"<#{@key}>"
		end
		
		def to_a
			usage = [self.to_s]
			
			if @commands.size == 0
				usage << "No commands available."
			elsif @commands.size == 1
				usage << "Only #{@commands.first}."
			else
				usage << "One of: #{@commands.keys.join(', ')}."
			end
			
			if @default
				usage << "(default: #{@default})"
			elsif @required
				usage << "(required)"
			end
			
			return usage
		end
		
		# @param default [Command] the default command if any.
		def parse(input, parent = nil, default = nil)
			if command = @commands[input.first]
				name = input.shift
				
				# puts "Instantiating #{command} with #{input}"
				command.new(input, name: name, parent: parent)
			elsif default
				return default
			elsif @default
				@commands[@default].new(input, name: @default, parent: parent)
			elsif @required
				raise MissingValueError.new(parent, self)
			end
		end
		
		def usage(rows)
			rows << self
			
			@commands.each do |key, klass|
				klass.usage(rows, key)
			end
		end
	end
end
