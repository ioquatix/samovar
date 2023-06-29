# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2019-2023, by Samuel Williams.

module Samovar
	class Error < StandardError
	end
		
	class InvalidInputError < Error
		def initialize(command, input)
			@command = command
			@input = input
			
			super "Could not parse token #{input.first.inspect}"
		end
		
		def token
			@input.first
		end
		
		def help?
			self.token == "--help"
		end
		
		attr :command
		attr :input
	end
	
	class MissingValueError < Error
		def initialize(command, field)
			@command = command
			@field = field
			
			super "#{field} is required"
		end
		
		attr :command
		attr :field
	end
end
