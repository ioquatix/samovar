# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2025, by Samuel Williams.
# Copyright, 2026, by Gerhard Schlager.

require "samovar"

describe Samovar::Output::UsageFormatter do
	let(:output) {StringIO.new}
	
	with "basic command" do
		let(:command_class) do
			Class.new(Samovar::Command) do
				self.description = "Test command for usage formatter"
				
				options do
					option "-v/--verbose", "Enable verbose output"
					option "-q/--quiet", "Enable quiet mode"
				end
			end
		end
		
		it "formats command usage" do
			command = command_class.new
			command.print_usage(output: output)
			
			expect(output.string).to be(:include?, "Test command for usage formatter")
			expect(output.string).to be(:include?, "--verbose")
			expect(output.string).to be(:include?, "--quiet")
		end
	end
	
	with "command with options and arguments" do
		let(:command_class) do
			Class.new(Samovar::Command) do
				self.description = "Complex command"
				
				options do
					option "--name <value>", "Specify a name", default: "default"
				end
				
				one :project, "The project to work with"
				many :files, "Files to process"
			end
		end
		
		it "formats all elements" do
			command = command_class.new
			command.print_usage(output: output)
			
			text = output.string
			expect(text).to be(:include?, "Complex command")
			expect(text).to be(:include?, "--name")
			expect(text).to be(:include?, "project")
			expect(text).to be(:include?, "files")
		end
	end
	
	with "nested commands" do
		let(:sub_command) do
			Class.new(Samovar::Command) do
				self.description = "Sub command description"
			end
		end
		
		let(:parent_command) do
			cmd = sub_command
			Class.new(Samovar::Command) do
				self.description = "Parent command"
				
				nested :command, {
					"sub" => cmd
				}
			end
		end
		
		it "formats nested structure" do
			command = parent_command.new
			command.print_usage(output: output)
			
			expect(output.string).to be(:include?, "Parent command")
			expect(output.string).to be(:include?, "sub")
		end
	end
	
	with "split arguments" do
		let(:command_class) do
			Class.new(Samovar::Command) do
				self.description = "Command with split args"
				
				split :args, "Arguments after --"
			end
		end
		
		it "formats split marker" do
			command = command_class.new
			command.print_usage(output: output)
			
			expect(output.string).to be(:include?, "--")
			expect(output.string).to be(:include?, "args")
		end
	end
	
	with "error handling" do
		let(:command_class) do
			Class.new(Samovar::Command) do
				self.description = "Command for testing errors"
				
				options do
					option "--flag", "A flag"
				end
			end
		end
		
		it "formats InvalidInputError" do
			# Call with invalid input - error will be printed to our output stream:
			result = command_class.call(["--unknown-flag"], output: output)
			
			expect(result).to be_nil
			
			# Verify error was formatted and printed:
			expect(output.string).to be(:include?, "Could not parse")
			expect(output.string).to be(:include?, "--unknown-flag")
		end
		
		it "skips help flag errors" do
			# The --help flag should not print an error message:
			result = command_class.call(["--help"], output: output)
			
			expect(result).to be_nil
			# Should not include error message for help:
			expect(output.string).not.to be(:include?, "Could not parse")
		end
	end
	
	with "custom formatter" do
		it "allows customization via block" do
			command_class = Class.new(Samovar::Command) do
				self.description = "Customizable command"
			end
			
			command = command_class.new
			block_called = false
			
			command.print_usage(output: output) do |formatter|
				block_called = true
				expect(formatter).to be_a(Samovar::Output::UsageFormatter)
			end
			
			expect(block_called).to be == true
		end
	end
	
	with "unsupported object" do
		it "raises an error for an unknown type" do
			formatter = Samovar::Output::UsageFormatter.new(output)
			
			expect do
				formatter.map(Object.new)
			end.to raise_exception(ArgumentError, message: be(:include?, "Unable to format"))
		end
	end
	
	with "first state propagation" do
		let(:command) do
			Struct.new(:description) do
				def command_line(name)
					"command #{name}"
				end
			end.new(nil)
		end
		
		let(:rows) do
			Samovar::Output::Rows.new.tap do |rows|
				rows.nested("test", command) do |nested|
					nested << ["--flag", "Flag description"]
				end
			end
		end
		
		it "returns false after formatting the first header" do
			formatter = Samovar::Output::UsageFormatter.new(output)
			header = Samovar::Output::Header.new("test", command)
			
			first = formatter.map(header, rows, first: true)
			
			expect(first).to be == false
		end
		
		it "prints a leading blank line when first is false" do
			formatter = Samovar::Output::UsageFormatter.new(output)
			
			formatter.print(rows, first: false)
			
			lines = output.string.lines
			expect(lines.first).to be == "\n"
			expect(lines[1]).to be(:include?, "command test")
		end
		
		it "does not persist first-state across separate print calls" do
			formatter = Samovar::Output::UsageFormatter.new(output)
			
			formatter.print(rows)
			formatter.print(rows)
			
			expect(output.string).not.to be(:include?, "\n\ncommand test")
		end
	end
end
