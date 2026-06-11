# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2026, by Samuel Williams.

require_relative "../../command"

module Samovar
	module Internal
		module Command
			# Generate shell completion adapter scripts for Samovar-based commands.
			class Completion < Samovar::Command
				self.description = "Generate shell completion adapter scripts."
				
				one :shell, "The shell to generate completions for.", pattern: /^(bash|zsh|fish)$/, required: true, completions: ["bash", "zsh", "fish"]
				one :executable, "The command executable to complete.", required: true
				
				def call
					output.puts Samovar::Completion.script(shell: @shell.to_sym, executable: @executable)
				end
			end
		end
	end
end
