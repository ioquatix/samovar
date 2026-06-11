# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2026, by Samuel Williams.

require_relative "../../command"
require_relative "completion"

module Samovar
	module Internal
		module Command
			# The Samovar command-line interface.
			class Top < Samovar::Command
				self.description = "Utilities for Samovar-based command-line applications."
				
				options do
					option "-h/--help", "Print out help information."
				end
				
				nested :command, {
					"completion" => Completion,
				}, required: true
				
				def call
					@command.call
				end
			end
		end
	end
end
