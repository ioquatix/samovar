# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2016-2023, by Samuel Williams.

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
			if method_defined?(row.key, false)
				warning "Method for key #{row.key} is already defined!", caller
				# raise ArgumentError, "Method for key #{row.key} is already defined!"
			end
			
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
		
		def initialize(input = nil, name: File.basename($0), parent: nil, output: nil)
			@name = name
			@parent = parent
			@output = output
			
			parse(input) if input
		end
		
		attr :output
		
		def output
			@output || $stdout
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
		
		def print_usage(output: self.output, formatter: Output::UsageFormatter, &block)
			rows = Output::Rows.new
			
			self.class.usage(rows, @name)
			
			formatter.print(rows, output, &block)
		end
	end
end
