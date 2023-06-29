# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2019-2023, by Samuel Williams.

require 'mapping/model'
require 'console/terminal'

require_relative '../error'

require_relative 'header'

require_relative 'row'
require_relative 'rows'

module Samovar
	module Output
		class UsageFormatter < Mapping::Model
			def self.print(rows, output)
				formatter = self.new(rows, output)
				
				yield formatter if block_given?
				
				formatter.print
			end
			
			def initialize(rows, output)
				@rows = rows
				@output = output
				@width = 80
				
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
				@terminal.puts unless header == @rows.first
				
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
			
			def print
				map(@rows)
			end
		end
	end
end
