# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2019-2025, by Samuel Williams.

require "mapping/model"
require "console/terminal"

require_relative "../error"

require_relative "header"

require_relative "row"
require_relative "rows"

module Samovar
	module Output
		# Formats and prints usage information to a terminal.
		# 
		# Uses the `mapping` gem to handle different output object types with custom formatting rules.
		class UsageFormatter < Mapping::Model
			# Print usage information to the output.
			# 
			# @parameter rows [Rows] The rows to format and print.
			# @parameter output [IO] The output stream to print to.
			# @yields {|formatter| ...} Optional block to customize the formatter.
			def self.print(rows, output)
				formatter = self.new(output)
				
				yield formatter if block_given?
				
				formatter.print(rows)
			end
			
			# Initialize a new usage formatter.
			# 
			# @parameter rows [Rows] The rows to format.
			# @parameter output [IO] The output stream to print to.
			def initialize(output)
				@output = output
				@width = 80
				@first = true
				
				@terminal = Console::Terminal.for(@output)
				@terminal[:header] = @terminal.style(nil, nil, :bright)
				@terminal[:description] = @terminal.style(:blue)
				@terminal[:error] = @terminal.style(:red)
			end
			
			map(InvalidInputError) do |error|
				# This is a little hack which avoids printing out "--help" if it was part of an incomplete parse. In the future I'd prefer if this was handled explicitly.
				@terminal.puts("#{error.message} in:", style: :error) unless error.help?
			end
			
			map(MissingValueError) do |error|
				@terminal.puts("#{error.message} in:", style: :error)
			end
			
			map(Header) do |header, rows|
				if @first
					@first = false
				else
					@terminal.puts
				end
				
				command_line = header.object.command_line(header.name)
				@terminal.puts "#{rows.indentation}#{command_line}", style: :header
				
				if description = header.object.description
					@terminal.puts "#{rows.indentation}\t#{description}", style: :description
					@terminal.puts
				end
			end
			
			map(Row) do |row, rows|
				@terminal.puts "#{rows.indentation}#{row.align(rows.columns)}"
			end
			
			map(Rows) do |items|
				items.collect{|row, rows| map(row, rows)}
			end
			
			# Print the formatted usage output.
			def print(rows, first: @first)
				@first = first
				map(rows)
			end
		end
	end
end
