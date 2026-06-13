# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2026, by Samuel Williams.

require "samovar/internal/command/top"

describe Samovar::Internal::Command::Completion do
	let(:temporary_root) {File.expand_path("../../../tmp", __dir__)}
	
	def temporary_path(*path)
		File.join(temporary_root, *path)
	end
	
	after do
		FileUtils.rm_rf(temporary_root)
	end
	
	it "generates a shell completion adapter script" do
		output = StringIO.new
		command = subject.new(["generate", "--shell", "zsh", "--command", "my-command"], output: output)
		
		command.call
		
		expect(output.string).to be(:include?, "#compdef my-command")
		expect(output.string).to be(:include?, "COMPLETION_INDEX")
	end
	
	it "requires the command name when generating" do
		expect do
			subject.new(["generate", "--shell", "zsh"])
		end.to raise_exception(Samovar::MissingValueError)
	end
	
	it "generates a shell completion adapter script with --command" do
		output = StringIO.new
		command = subject.new(["--shell", "zsh", "--command", "my-command"], output: output)
		
		command.call
		
		expect(output.string).to be(:include?, "#compdef my-command")
		expect(output.string).to be(:include?, "COMPLETION_INDEX")
	end
	
	it "infers shell when generating" do
		output = StringIO.new
		shell = ENV["SHELL"]
		
		begin
			ENV["SHELL"] = "/bin/fish"
			
			command = subject.new(["--command", "my-command"], output: output)
			command.call
		ensure
			ENV["SHELL"] = shell
		end
		
		expect(output.string).to be(:include?, "complete -c my-command")
	end
	
	it "installs a shell completion adapter script to an explicit directory" do
		output = StringIO.new
		directory = temporary_path("zsh")
		command = subject.new(["install", "--shell", "zsh", "--directory", directory, "--command", "my-command"], output: output)
		
		command.call
		
		path = File.join(directory, "_my-command")
		expect(output.string).to be == "#{path}\n"
		expect(File.read(path)).to be(:include?, "#compdef my-command")
		expect(File.read(path)).to be(:include?, "COMPLETION_INDEX")
	end
	
	it "infers shell and default directory when installing" do
		output = StringIO.new
		shell = ENV["SHELL"]
		home = ENV["HOME"]
		
		begin
			ENV["SHELL"] = "/bin/fish"
			ENV["HOME"] = temporary_path("home")
			
			command = subject.new(["install", "--command", "my-command"], output: output)
			command.call
		ensure
			ENV["SHELL"] = shell
			ENV["HOME"] = home
		end
		
		path = temporary_path("home", ".config", "fish", "completions", "my-command.fish")
		expect(output.string).to be == "#{path}\n"
		expect(File.read(path)).to be(:include?, "complete -c my-command")
	end
	
	it "can be invoked through the top-level command" do
		output = StringIO.new
		
		Samovar::Internal::Command::Top.new(["completion", "--shell", "bash", "--command", "my-command"], output: output).call
		
		expect(output.string).to be(:include?, "complete -F _my_command_completion my-command")
	end
	
	it "completes shell names" do
		result = Samovar::Internal::Command::Top.complete(["completion", "--shell", "z"], index: 2)
		
		expect(result.collect(&:value)).to be == ["zsh"]
	end
	
	it "completes the detected shell before other shell names" do
		shell = ENV["SHELL"]
		
		begin
			ENV["SHELL"] = "/bin/fish"
			
			result = Samovar::Internal::Command::Top.complete(["completion", "--shell"], index: 2)
		ensure
			ENV["SHELL"] = shell
		end
		
		expect(result.collect(&:value)).to be == ["fish", "bash", "zsh"]
	end
	
	it "completes install shell option values" do
		result = Samovar::Internal::Command::Top.complete(["completion", "install", "--shell", "f"], index: 3)
		
		expect(result.collect(&:value)).to be == ["fish"]
	end
end
