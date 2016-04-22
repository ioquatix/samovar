
require 'flopp'

module Command
	class Bottom < Flop::Command
		self.description = "Create a new teapot package using the specified repository."
		
		one :project_name, "The name of the new project in title-case, e.g. 'My Project'."
		many :packages, "Any additional packages you'd like to include in the project."
		split :argv, "Additional arguments to be passed to the sub-process."
	end

	class Top < Flop::Command
		self.description = "A decentralised package manager and build tool."
		
		options do
			option '-c/--configuration <name>', "Specify a specific build configuration.", default: ENV['TEAPOT_CONFIGURATION']
			option '-i/--in/--root <path>', "Work in the given root directory."
			option '--verbose | --quiet', "Verbosity of output for debugging.", key: :logging
			option '-h/--help', "Print out help information."
			option '-v/--version', "Print out the application version."
		end
		
		nested '<command>',
			'bottom' => Bottom
	end
end

describe Flopp do
	it "should parse a simple command" do
		top = Command::Top.parse(["-c", "path", "bottom", "foobar", "A", "B", "--", "args", "args"])
		
		expect(top.options[:configuration]).to be == 'path'
		expect(top.command.class).to be == Command::Bottom
		expect(top.command.project_name).to be == 'foobar'
		expect(top.command.packages).to be == ['A', 'B']
		expect(top.command.argv).to be == ["args", "args"]
	end
end
