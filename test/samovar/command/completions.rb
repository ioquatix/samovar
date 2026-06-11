# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2026, by Samuel Williams.

require "samovar/command/completions"

describe Samovar::CommandLine::Completions do
	it "generates a shell completion adapter script" do
		output = StringIO.new
		command = subject.new(["zsh", "my-command"], output: output)
		
		command.call
		
		expect(output.string).to be(:include?, "#compdef my-command")
		expect(output.string).to be(:include?, "SAMOVAR_COMPLETE")
	end
	
	it "can be invoked through the top-level command" do
		output = StringIO.new
		
		Samovar::CommandLine::Top.new(["completions", "bash", "my-command"], output: output).call
		
		expect(output.string).to be(:include?, "complete -F _my_command_completion my-command")
	end
	
	it "completes shell names" do
		result = Samovar::CommandLine::Top.complete(["completions", "z"], index: 1)
		
		expect(result.collect(&:value)).to be == ["zsh"]
	end
end
