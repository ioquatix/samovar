# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2026, by Samuel Williams.

require_relative "../../command"
require_relative "../../failure"
require "fileutils"

module Samovar
	module Internal
		module Command
			# Generate or install shell completion adapter scripts for Samovar-based commands.
			class Completion < Samovar::Command
				# Generate shell completion adapter scripts for Samovar-based commands.
				class Generate < Samovar::Command
					self.description = "Generate shell completion adapter scripts."
					
					options do
						option "--command <name>", "The command executable to complete."
					end
					
					one :shell, "The shell to generate completions for.", pattern: /^(bash|zsh|fish)$/, required: true, completions: ["bash", "zsh", "fish"]
					one :executable, "The command executable to complete.", default: nil
					
					def call
						executable = @options[:command] || @executable
						raise MissingValueError.new(self, :command) unless executable
						
						output.puts Samovar::Completion.script(shell: @shell.to_sym, executable: executable)
					end
				end
				
				# Install a shell completion adapter script to a user-local completion directory.
				class Install < Samovar::Command
					self.description = "Install a shell completion adapter script."
					
					options do
						option "--shell <name>", "The shell to install completions for.", completions: ["bash", "zsh", "fish"]
						option "--directory <path>", "The completion directory to install into."
						option "--command <name>", "The command executable to complete."
					end
					
					one :executable, "The command executable to complete.", default: nil
					
					def self.shell_name(path)
						File.basename(path.to_s)
					end
					
					def self.default_directory(shell)
						case shell
						when "bash"
							File.expand_path("~/.local/share/bash-completion/completions")
						when "fish"
							File.expand_path("~/.config/fish/completions")
						when "zsh"
							File.expand_path("~/.zsh/completions")
						else
							raise Failure, "Unsupported shell: #{shell.inspect}"
						end
					end
					
					def self.file_name(shell, executable)
						case shell
						when "bash"
							executable
						when "fish"
							"#{executable}.fish"
						when "zsh"
							"_#{executable}"
						else
							raise Failure, "Unsupported shell: #{shell.inspect}"
						end
					end
					
					def call
						executable = @options[:command] || @executable
						raise MissingValueError.new(self, :command) unless executable
						
						shell = @options[:shell] || self.class.shell_name(ENV["SHELL"])
						directory = @options[:directory] || self.class.default_directory(shell)
						path = File.join(directory, self.class.file_name(shell, executable))
						script = Samovar::Completion.script(shell: shell.to_sym, executable: executable)
						
						FileUtils.mkdir_p(directory)
						File.write(path, script)
						
						output.puts path
					end
				end
				
				self.description = "Generate or install shell completion adapter scripts."
				
				nested :command, {
					"install" => Install,
					"generate" => Generate,
				}, default: "generate"
				
				def call
					@command.call
				end
			end
		end
	end
end
