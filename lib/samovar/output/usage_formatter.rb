# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2019-2025, by Samuel Williams.
# Copyright, 2026, by Gerhard Schlager.

require "console/terminal"

require_relative "../error"

require_relative "header"

require_relative "row"
require_relative "rows"

module Samovar
	module Output
		# Formats and prints usage information to a terminal.
		# 
		# Dispatches on the type of each output object to apply custom formatting rules.
		class UsageFormatter
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
			
			# Format and print the given object according to its type.
			# 
			# @parameter object [Object] The object to format (a {Rows}, {Row}, {Header}, or error).
			# @parameter arguments [Array] Extra context passed through to nested rows (the containing {Rows}).
			def map(object, *arguments)
				case object
				when InvalidInputError
					# This is a little hack which avoids printing out "--help" if it was part of an incomplete parse. In the future I'd prefer if this was handled explicitly.
					@terminal.puts("#{object.message} in:", style: :error) unless object.help?
				when MissingValueError
					@terminal.puts("#{object.message} in:", style: :error)
				when Header
					header, rows = object, arguments.first
					
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
				when Row
					row, rows = object, arguments.first
					@terminal.puts "#{rows.indentation}#{row.align(rows.columns)}"
				when Rows
					object.collect{|row, rows| map(row, rows)}
				else
					raise ArgumentError, "Unable to format #{object.class}!"
				end
			end
			
			# Print the formatted usage output.
			def print(rows, first: @first)
				@first = first
				map(rows)
			end
		end
	end
end
