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

module Samovar
	class SystemError < RuntimeError
	end
	
	class Command
		def system(*args, **options)
			command_line = args.join(' ')
			
			pid = Process.spawn(*args, **options)
			
			puts Rainbow(command_line).color(:blue)
			
			status = Process.waitpid2(pid).last
			
			return status.success?
		rescue Errno::ENOENT
			return false
		end
		
		def system!(*args, **options)
			command_line = args.join(' ')
			
			pid = Process.spawn(*args, **options)
			
			puts Rainbow(command_line).color(:blue)
			
			status = Process.waitpid2(pid).last
			
			if status.success?
				return true
			else
				raise SystemError.new("Command #{command_line.dump} failed: #{status.to_s}")
			end
		rescue Errno::ENOENT
			raise SystemError.new("Command #{command_line.dump} failed: #{$!}")
		end
	end
end
