# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2019-2023, by Samuel Williams.

module Samovar
	module Output
		# Represents a header row in usage output.
		# 
		# Headers display command names and their descriptions.
		class Header
			# Initialize a new header.
			# 
			# @parameter name [String] The command name.
			# @parameter object [Command] The command class.
			def initialize(name, object)
				@name = name
				@object = object
			end
			
			# The command name.
			# 
			# @attribute [String]
			attr :name
			
			# The command class.
			# 
			# @attribute [Command]
			attr :object
			
			# Generate an aligned header string.
			# 
			# @parameter columns [Columns] The columns for alignment (unused for headers).
			# @returns [String] The command line usage string.
			def align(columns)
				@object.command_line(@name)
			end
		end
	end
end
