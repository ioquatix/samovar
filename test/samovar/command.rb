# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2016-2024, by Samuel Williams.

require 'samovar'

class Bottom < Samovar::Command
	self.description = "Create a new teapot package using the specified repository."
	
	one :project_name, "The name of the new project in title-case, e.g. 'My Project'."
	many :packages, "Any additional packages you'd like to include in the project."
	split :argv, "Additional arguments to be passed to the sub-process."
end

class Top < Samovar::Command
	self.description = "A decentralised package manager and build tool."
	
	options do
		option '-c/--configuration <name>', "Specify a specific build configuration.", default: 'TEAPOT_CONFIGURATION'
		option '-i/--in/--root <path>', "Work in the given root directory."
		option '--verbose | --quiet', "Verbosity of output for debugging.", key: :logging
		option '--[no]-color', "Enable or disable color output.", default: true
		option '-h/--help', "Print out help information."
		option '-v/--version', "Print out the application version."
	end
	
	nested :command, {
		'bottom' => Bottom
	}
end

describe Samovar::Command do
	it "should invoke call" do
		mock(Top) do |mock|
			mock.after(:new) do |instance|
				expect(instance).to receive(:call).and_return(true)
			end
		end
		
		Top.call([])
	end
	
	it "should use default value" do
		top = Top[]
		expect(top.options[:configuration]).to be == 'TEAPOT_CONFIGURATION'
	end
	
	it "can update options" do
		top = Top[]
		expect(top.options[:configuration]).to be == 'TEAPOT_CONFIGURATION'
		
		top = top['--verbose']
		expect(top.options[:configuration]).to be == 'TEAPOT_CONFIGURATION'
		expect(top.options[:logging]).to be == :verbose
	end
	
	it "should parse a simple command" do
		top = Top["-c", "path", "bottom", "foobar", "A", "B", "--", "args", "args"]
		
		expect(top.options[:configuration]).to be == 'path'
		expect(top.command.class).to be == Bottom
		expect(top.command.project_name).to be == 'foobar'
		expect(top.command.packages).to be == ['A', 'B']
		expect(top.command.argv).to be == ["args", "args"]
	end
	
	it "should generate documentation" do
		top = Top[]
		buffer = StringIO.new
		top.print_usage(output: buffer)
		
		expect(buffer.string).to be(:include?, Top.description)
	end
	
	with "specific output" do
		it "can print usage to specified outputn buffer" do
			buffer = StringIO.new
			top = Top[output: buffer]
			top.print_usage
			
			expect(buffer.string).to be(:include?, Top.description)
		end
	end
	
	with '--[no]-color flag' do
		it "should use default color output if unspecified" do
			top = Top[]
			expect(top.options[:color]).to be == true
		end
		
		it "should enable color output" do
			top = Top['--color']
			expect(top.options[:color]).to be == true
		end
		
		it "should disable color output" do
			top = Top['--no-color']
			expect(top.options[:color]).to be == false
		end
	end
end
