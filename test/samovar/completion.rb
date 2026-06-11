# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2026, by Samuel Williams.

require "samovar"
require "sus/fixtures/temporary_directory_context"

class CompletionLeaf < Samovar::Command
	self.description = "Leaf command."
	
	def self.path_completions(context)
		["app.rb", "readme.md", "test.rb"]
	end
	
	options do
		option "--format <name>", "The output format.", completions: ["json", "text", "yaml"]
		option "--verbose | --quiet", "Verbosity of output for debugging.", key: :logging
		option "--[no]-color", "Enable or disable color output.", default: true
	end
	
	one :path, "The path to process.", completions: method(:path_completions)
	many :extras, "Extra values.", completions: ->(context){["extra-a", "extra-b", context.environment["EXTRA"]].compact}
	split :argv, "Additional arguments.", completions: ["--child"]
end

class CompletionList < Samovar::Command
	self.description = "List things."
	
	options do
		option "--all", "List all things."
	end
end

class CompletionTop < Samovar::Command
	self.description = "Top command."
	
	options do
		option "-c/--configuration <name>", "Specify a configuration."
		option "-v/--verbose", "Enable verbose output."
	end
	
	nested :command, {
		"leaf" => CompletionLeaf,
		"list" => CompletionList,
	}, default: "leaf"
end

describe Samovar::Completion do
	include Sus::Fixtures::TemporaryDirectoryContext
	
	def values(result)
		result.collect(&:value)
	end
	
	it "completes top-level option flags" do
		result = CompletionTop.complete(["--ver"], index: 0)
		
		expect(values(result)).to be == ["--verbose"]
	end
	
	it "completes top-level options and commands for an empty token" do
		result = CompletionTop.complete([], index: 0)
		
		expect(values(result)).to be == ["--configuration", "-c", "--verbose", "-v", "leaf", "list"]
	end
	
	it "completes nested command names" do
		result = CompletionTop.complete(["le"], index: 0)
		
		expect(values(result)).to be == ["leaf"]
	end
	
	it "completes nested command options" do
		result = CompletionTop.complete(["leaf", "--no"], index: 1)
		
		expect(values(result)).to be == ["--no-color"]
	end
	
	it "completes boolean flag variants" do
		result = CompletionTop.complete(["leaf", "--"], index: 1)
		
		expect(values(result)).to be(:include?, "--color")
		expect(values(result)).to be(:include?, "--no-color")
	end
	
	it "completes option values using static completions" do
		result = CompletionTop.complete(["leaf", "--format", "j"], index: 2)
		
		expect(values(result)).to be == ["json"]
	end
	
	it "completes option values after a trailing option flag" do
		result = CompletionTop.complete(["leaf", "--format"], index: 2)
		
		expect(values(result)).to be == ["json", "text", "yaml"]
	end
	
	it "completes positional values using method completions" do
		result = CompletionTop.complete(["leaf", "r"], index: 1)
		
		expect(values(result)).to be == ["readme.md"]
	end
	
	it "completes many values using callable completions" do
		result = CompletionTop.complete(["leaf", "app.rb", "e"], index: 2, environment: {"EXTRA" => "env-extra"})
		
		expect(values(result)).to be == ["extra-a", "extra-b", "env-extra"]
	end
	
	it "completes split marker before many consumes option-looking tokens" do
		result = CompletionTop.complete(["leaf", "app.rb", "--"], index: 2)
		
		expect(values(result)).to be == ["--"]
	end
	
	it "completes split values after the marker" do
		result = CompletionTop.complete(["leaf", "app.rb", "--", "--c"], index: 3)
		
		expect(values(result)).to be == ["--child"]
	end
	
	it "uses default nested command for option-looking completions" do
		result = CompletionTop.complete(["--no"], index: 0)
		
		expect(values(result)).to be == ["--no-color"]
	end
	
	it "prints completion results as TSV" do
		output = StringIO.new
		result = CompletionTop.complete(["le"], index: 0)
		
		subject.print(result, output)
		
		expect(output.string).to be == "leaf\tLeaf command.\tcommand\n"
	end
	
	it "uses SAMOVAR_COMPLETE as the cursor index in call" do
		output = StringIO.new
		
		begin
			ENV["SAMOVAR_COMPLETE"] = "0"
			result = CompletionTop.call(["le"], completion_output: output)
		ensure
			ENV.delete("SAMOVAR_COMPLETE")
		end
		
		expect(result).to be == true
		expect(output.string).to be == "leaf\tLeaf command.\tcommand\n"
	end
	
	it "generates shell completion scripts" do
		expect(subject.script(shell: :bash, executable: "samovar")).to be(:include?, "SAMOVAR_COMPLETE")
		expect(subject.script(shell: :zsh, executable: "samovar")).to be(:include?, "#compdef samovar")
		expect(subject.script(shell: :fish, executable: "samovar")).to be(:include?, "complete -c samovar")
	end
	
	it "uses zsh array indexing to remove the command word" do
		script = subject.script(shell: :zsh, executable: "samovar")
		
		expect(script).to be(:include?, 'argv=("${words[2,-1]}")')
	end
	
	it "passes application arguments from zsh completion" do
		skip "zsh is not available" unless system("command -v zsh >/dev/null")
		
		path = File.join(root, "trace")
		
		system({"TRACE" => path}, "zsh", "-fc", <<~SCRIPT)
			samovar() {
				print -r -- "$SAMOVAR_COMPLETE|$*" > "$TRACE"
				print -r -- "completion\\tGenerate\\tcommand"
			}
			
			_describe() { :; }
			
			words=(samovar completion --shell z)
			CURRENT=4
			
			source <(ruby -Ilib bin/samovar completion --command samovar --shell zsh)
		SCRIPT
		
		expect(File.read(path)).to be == "2|completion --shell z\n"
	end
	
	it "passes application arguments from fish completion" do
		skip "fish is not available" unless system("command -v fish >/dev/null")
		
		path = File.join(root, "fish-trace")
		directory = File.join(root, "fish-command")
		executable = File.join(directory, "samovar")
		
		Dir.mkdir(directory)
		File.write(executable, <<~SCRIPT)
			#!/bin/sh
			printf "%s|%s\\n" "$SAMOVAR_COMPLETE" "$*" >> "$TRACE"
			printf "completion\\tGenerate\\tcommand\\n"
		SCRIPT
		File.chmod(0o755, executable)
		
		system({"TRACE" => path}, "fish", "--no-config", "-c", <<~SCRIPT)
			complete -e -c samovar
			source (ruby -Ilib bin/samovar completion --command #{executable} --shell fish | psub)
			complete --do-complete "samovar completion --shell z" >/dev/null
		SCRIPT
		
		expect(File.readlines(path)).to be(:include?, "2|completion --shell z\n")
	end
	
	it "passes an empty token from fish completion" do
		skip "fish is not available" unless system("command -v fish >/dev/null")
		
		path = File.join(root, "fish-empty-trace")
		directory = File.join(root, "fish-empty-command")
		executable = File.join(directory, "samovar")
		
		Dir.mkdir(directory)
		File.write(executable, <<~SCRIPT)
			#!/bin/sh
			printf "%s|%s\\n" "$SAMOVAR_COMPLETE" "$*" >> "$TRACE"
			printf "completion\\tGenerate\\tcommand\\n"
		SCRIPT
		File.chmod(0o755, executable)
		
		system({"TRACE" => path}, "fish", "--no-config", "-c", <<~SCRIPT)
			complete -e -c samovar
			source (ruby -Ilib bin/samovar completion --command #{executable} --shell fish | psub)
			complete --do-complete "samovar " >/dev/null
		SCRIPT
		
		expect(File.readlines(path)).to be(:include?, "0|\n")
	end
	
	it "uses the basename when registering completion scripts" do
		zsh = subject.script(shell: :zsh, executable: "./samovar")
		bash = subject.script(shell: :bash, executable: "./samovar")
		fish = subject.script(shell: :fish, executable: "./samovar")
		
		expect(zsh).to be(:include?, "#compdef samovar")
		expect(zsh).to be(:include?, "_samovar_completion()")
		expect(bash).to be(:include?, "complete -F _samovar_completion samovar")
		expect(fish).to be(:include?, "complete -c samovar")
	end
end
