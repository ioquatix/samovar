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

require_relative 'error'

module Samovar
	class Command
		def self.call(input = ARGV)
			if command = self.parse(input)
				command.call
			end
		end
		
		# The top level entry point for parsing ARGV.
		def self.parse(input)
			self.new(input)
		rescue Error => error
			error.command.print_usage(output: $stderr) do |formatter|
				formatter.map(error)
			end
			
			return nil
		end
		
		def self.[](*input, **options)
			self.new(input, **options)
		end
		
		class << self
			attr_accessor :description
		end
		
		def self.table
			@table ||= Table.nested(self)
		end
		
		def self.append(row)
			attr_accessor(row.key) if row.respond_to?(:key)
			
			self.table << row
		end
		
		def self.options(*arguments, **options, &block)
			append Options.parse(*arguments, **options, &block)
		end
		
		def self.nested(*arguments, **options)
			append Nested.new(*arguments, **options)
		end
		
		def self.one(*arguments, **options)
			append One.new(*arguments, **options)
		end
		
		def self.many(*arguments, **options)
			append Many.new(*arguments, **options)
		end
		
		def self.split(*arguments, **options)
			append Split.new(*arguments, **options)
		end
		
		def self.usage(rows, name)
			rows.nested(name, self) do |rows|
				return unless table = self.table.merged
				
				table.each do |row|
					if row.respond_to?(:usage)
						row.usage(rows)
					else
						rows << row
					end
				end
			end
		end
		
		def self.command_line(name)
			if table = self.table.merged
				"#{name} #{table.merged.usage}"
			else
				name
			end
		end
		
		def initialize(input = nil, name: File.basename($0), parent: nil)
			@name = name
			@parent = parent
			
			parse(input) if input
		end
		
		def to_s
			self.class.name
		end
		
		attr :name
		attr :parent
		
		def [](*input)
			self.dup.tap{|command| command.parse(input)}
		end
		
		def parse(input)
			self.class.table.merged.parse(input, self)
			
			if input.empty?
				return self
			else
				raise InvalidInputError.new(self, input)
			end
		end
		
		def print_usage(output: $stderr, formatter: Output::UsageFormatter, &block)
			rows = Output::Rows.new
			
			self.class.usage(rows, @name)
			
			formatter.print(rows, output, &block)
		end
	end
end
