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

require_relative 'option'

module Samovar
	class Options
		def self.parse(*arguments, **options, &block)
			options = self.new(*arguments, **options)
			
			options.instance_eval(&block) if block_given?
			
			return options.freeze
		end
		
		def initialize(title = "Options", key: :options)
			@title = title
			@ordered = []
			
			# We use this flag to option cache to improve parsing performance:
			@keyed = {}
			
			@key = key
			
			@defaults = {}
		end
		
		def initialize_dup(source)
			super
			
			@ordered = @ordered.dup
			@keyed = @keyed.dup
			@defaults = @defaults.dup
		end
		
		attr :title
		attr :ordered
		
		attr :key
		attr :defaults
		
		def freeze
			return self if frozen?
			
			@ordered.freeze
			@keyed.freeze
			@defaults.freeze
			
			@ordered.each(&:freeze)
			
			super
		end
		
		def each(&block)
			@ordered.each(&block)
		end
		
		def empty?
			@ordered.empty?
		end
		
		def option(*arguments, **options, &block)
			self << Option.new(*arguments, **options, &block)
		end
		
		def merge!(options)
			options.each do |option|
				self << option
			end
		end
		
		def << option
			@ordered << option
			option.flags.each do |flag|
				@keyed[flag.prefix] = option
				
				flag.alternatives.each do |alternative|
					@keyed[alternative] = option
				end
			end
			
			if default = option.default
				@defaults[option.key] = option.default
			end
		end
		
		def parse(input, parent = nil, default = nil)
			values = (default || @defaults).dup
			
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
