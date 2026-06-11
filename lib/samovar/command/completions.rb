# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2026, by Samuel Williams.

require_relative "../command"

module Samovar
	module CommandLine
		# Generate shell completion adapter scripts for Samovar-based commands.
		class Completions < Command
			self.description = "Generate shell completion adapter scripts."
			
			one :shell, "The shell to generate completions for.", pattern: /^(bash|zsh|fish)$/, required: true, completions: ["bash", "zsh", "fish"]
			one :executable, "The command executable to complete.", required: true
			
			def call
				output.puts Completion.script(shell: @shell.to_sym, executable: @executable)
			end
		end
		
		# The Samovar command-line interface.
		class Top < Command
			self.description = "Utilities for Samovar-based command-line applications."
			
			options do
				option "-h/--help", "Print out help information."
			end
			
			nested :command, {
				"completions" => Completions,
			}, required: true
			
			def call
				@command.call
			end
		end
	end
end
