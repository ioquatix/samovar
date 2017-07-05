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

require_relative 'table'
require_relative 'options'
require_relative 'nested'
require_relative 'one'
require_relative 'many'
require_relative 'split'

require_relative 'output'

require_relative 'command/system'
require_relative 'command/track_time'

module Samovar
	class IncompleteParse < StandardError
	end
	
	class Command
		def self.parse(input)
			command = self.new(input)
			
			raise IncompleteParse.new("Could not parse #{input}") unless input.empty?
			
			return command
		end
		
		def self.[](*input)
			self.parse(input)
		end
		
		def [](*input)
			self.dup.tap{|command| command.parse(input)}
		end
		
		def parse(input)
			self.class.table.parse(input) do |key, value|
				self.send("#{key}=", value)
			end
		end
		
		def initialize(input = nil)
			parse(input) if input
		end
		
		class << self
			attr_accessor :description
		end
		
		def self.table
			@table ||= Table.new
		end
		
		def self.append(row)
			attr_accessor(row.key) if row.respond_to?(:key)
			
			self.table << row
		end
		
		def self.options(*args, **options, &block)
			append Options.parse(*args, **options, &block)
		end
		
		def self.nested(*args, **options)
			append Nested.new(*args, **options)
		end
		
		def self.one(*args, **options)
			append One.new(*args, **options)
		end
		
		def self.many(*args, **options)
			append Many.new(*args, **options)
		end
		
		def self.split(*args, **options)
			append Split.new(*args, **options)
		end
		
		def self.usage(rows, name)
			rows.nested(name, self) do |rows|
				return unless @table
				
				@table.rows.each do |row|
					if row.respond_to?(:usage)
						row.usage(rows)
					else
						rows << row
					end
				end
			end
		end
		
		def self.command_line(name)
			if @table
				"#{name} #{@table.usage}"
			else
				name
			end
		end
		
		def print_usage(*args, output: $stderr, formatter: Output::DetailedFormatter)
			rows = Output::Rows.new
			
			self.class.usage(rows, *args)
			
			formatter.print(rows, output)
		end
	end
end
