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

require_relative 'flags'

module Samovar
	class Option
		def initialize(flags, description, key: nil, default: nil, value: nil)
			@flags = Flags.new(flags)
			@description = description
			
			if key
				@key = key
			else
				@key = @flags.first.key
			end
			
			@default = default
			
			@value = value
			@value ||= true if @flags.boolean?
		end
		
		attr :flags
		attr :description
		attr :type
		
		attr :key
		
		def parse(input)
			if result = @flags.parse(input)
				@value.nil? ? result : @value
			else
				@default
			end
		end
		
		def to_s
			@flags
		end
		
		def to_a
			unless @default.nil?
				[@flags, @description, "Default: #{@default}"]
			else
				[@flags, @description]
			end
		end
	end
	
	class Options
		def self.parse(*args, **options, &block)
			options = self.new(*args, **options)
			
			options.instance_eval(&block) if block_given?
			
			return options
		end
		
		def initialize(title = "Options", key: :options)
			@title = title
			@ordered = []
			@keyed = {}
			@key = key
		end
		
		attr :key
		
		def option(*args, **options)
			self << Option.new(*args, **options)
		end
		
		def << option
			@ordered << option
			option.flags.each do |flag|
				@keyed[flag.prefix] = option
				
				flag.alternatives.each do |alternative|
					@keyed[alternative] = option
				end
			end
		end
		
		def parse(input)
			values = Hash.new
			
			while option = @keyed[input.first]
				if result = option.parse(input)
					values[option.key] = result
				end
			end
			
			return values
		end
		
		def to_s
			@ordered.collect(&:to_s).join(' ')
		end
		
		def usage(rows)
			@ordered.each do |option|
				rows << option
			end
		end
	end
end