
require 'samovar'
require 'stringio'

module Command
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
			option '-h/--help', "Print out help information."
			option '-v/--version', "Print out the application version."
		end
		
		nested '<command>',
			'bottom' => Bottom
	end
end

describe Samovar::Command do
	it "should use default value" do
		top = Command::Top.parse([])
		expect(top.options[:configuration]).to be == 'TEAPOT_CONFIGURATION'
	end
	
	it "should parse a simple command" do
		top = Command::Top.parse(["-c", "path", "bottom", "foobar", "A", "B", "--", "args", "args"])
		
		expect(top.options[:configuration]).to be == 'path'
		expect(top.command.class).to be == Command::Bottom
		expect(top.command.project_name).to be == 'foobar'
		expect(top.command.packages).to be == ['A', 'B']
		expect(top.command.argv).to be == ["args", "args"]
	end
	
	it "should generate documentation" do
		top = Command::Top.new([])
		buffer = StringIO.new
		top.print_usage('top', output: buffer)
		
		expect(buffer.string).to be_include(Command::Top.description)
	end
	
	it "can run commands" do
		expect(subject.system("ls")).to be_truthy
		expect(subject.system!("ls")).to be_truthy
		
		expect(subject.system("fail")).to be_falsey
		expect{subject.system!("fail")}.to raise_error(Samovar::SystemError)
	end
end
