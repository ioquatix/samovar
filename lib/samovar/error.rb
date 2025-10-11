# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2019-2025, by Samuel Williams.

module Samovar
	# The base class for all Samovar errors.
	class Error < StandardError
	end
	
	# Raised when invalid input is provided on the command line.
	class InvalidInputError < Error
		# Initialize a new invalid input error.
		# 
		# @parameter command [Command] The command that encountered the error.
		# @parameter input [Array(String)] The remaining input that could not be parsed.
		def initialize(command, input)
			@command = command
			@input = input
			
			super "Could not parse token #{input.first.inspect}"
		end
		
		# The token that could not be parsed.
		# 
		# @returns [String] The first unparsed token.
		def token
			@input.first
		end
		
		# Check if the error was caused by a help request.
		# 
		# @returns [Boolean] True if the token is `--help`.
		def help?
			self.token == "--help"
		end
		
		# The command that encountered the error.
		# 
		# @attribute [Command]
		attr :command
		
		# The remaining input that could not be parsed.
		# 
		# @attribute [Array(String)]
		attr :input
	end
	
	# Raised when a required value is missing.
	class MissingValueError < Error
		# Initialize a new missing value error.
		# 
		# @parameter command [Command] The command that encountered the error.
		# @parameter field [Symbol] The name of the missing field.
		def initialize(command, field)
			@command = command
			@field = field
			
			super "#{field} is required"
		end
		
		# The command that encountered the error.
		# 
		# @attribute [Command]
		attr :command
		
		# The name of the missing field.
		# 
		# @attribute [Symbol]
		attr :field
	end
end
