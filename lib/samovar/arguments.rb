# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2016-2025, by Samuel Williams.

module Samovar
	# Utility helpers for adapting command-line argument arrays before parsing.
	module Arguments
		# Rewrite selected `--key=value` tokens into `--key value` pairs.
		#
		# @parameter input [Array(String)] The input arguments.
		# @parameter keys [Array(String)] The exact keys to normalize.
		# @returns [Array(String)] The transformed argument array.
		def self.transform(input, keys:)
			keys = keys.collect(&:to_s)
			
			return input.collect do |token|
				if token&.include?("=")
					key, value = token.split("=", 2)
					if keys.include?(key)
						[key, value]
					else
						token
					end
				else
					token
				end
			end.flatten(1)
		end
	end
end