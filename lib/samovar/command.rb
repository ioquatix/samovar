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

module Samovar
	class IncompleteParse < StandardError
		def initialize(command, input)
			@command = command
			@input = input
			
			super "Could not parse token: #{input.first}"
		end
		
		attr :command
		attr :input
	end
	
	class Command
		# The top level entry point for parsing ARGV.
		def self.parse(input = ARGV)
			self.new(input)
		rescue IncompleteParse => error
			$stderr.puts error.message
			
			error.command.print_usage(output: $stderr)
			
			return nil
		end
		
		def self.[](*input)
			self.new(input)
		end
		
		class << self
			attr_accessor :description
		end
		
		def self.table
			@table ||= Table.new(superclass == Command ? nil : superclass.table)
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
				return if @table.nil?
				
				@table.merged.each do |row|
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
				"#{name} #{@table.merged.usage}"
			else
				name
			end
		end
		
		def initialize(input = nil, name: File.basename($0))
			@name = name
			
			parse(input) if input
		end
		
		def [](*input)
			self.dup.tap{|command| command.parse(input)}
		end
		
		def parse(input)
			self.class.table.merged.parse(input, self)
			
			if input.empty?
				return self
			else
				raise IncompleteParse.new(self, input)
			end
		end
		
		def print_usage(*args, output: $stderr, formatter: Output::DetailedFormatter)
			rows = Output::Rows.new
			
			self.class.usage(rows, @name)
			
			formatter.print(rows, output)
		end
	end
end
