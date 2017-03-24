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

require 'time'
require 'shellwords'

module Samovar
	class SystemError < RuntimeError
	end
	
	class Command
		def system(*args, **options)
			log_system(args, options)
			
			Kernel::system(*args, **options)
		rescue Errno::ENOENT
			return false
		end
		
		def system!(*args, **options)
			if system(*args, **options)
				return true
			else
				raise SystemError.new("Command #{args.first.inspect} failed: #{$?.to_s}")
			end
		end
		
		private
		
		def log_system(args, options)
			# Print out something half-decent:
			command_line = Shellwords.join(args)
			puts Rainbow(command_line).color(:blue)
		end
	end
end
