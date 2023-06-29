# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2016-2023, by Samuel Williams.

require_relative 'option'

module Samovar
	class Options
		def self.parse(*arguments, **options, &block)
			options = self.new(*arguments, **options)
			
			options.instance_eval(&block) if block_given?
			
			return options.freeze
		end
		
		def initialize(title = "Options", key: :options)
			@title = title
			@ordered = []
			
			# We use this flag to option cache to improve parsing performance:
			@keyed = {}
			
			@key = key
			
			@defaults = {}
		end
		
		def initialize_dup(source)
			super
			
			@ordered = @ordered.dup
			@keyed = @keyed.dup
			@defaults = @defaults.dup
		end
		
		attr :title
		attr :ordered
		
		attr :key
		attr :defaults
		
		def freeze
			return self if frozen?
			
			@ordered.freeze
			@keyed.freeze
			@defaults.freeze
			
			@ordered.each(&:freeze)
			
			super
		end
		
		def each(&block)
			@ordered.each(&block)
		end
		
		def empty?
			@ordered.empty?
		end
		
		def option(*arguments, **options, &block)
			self << Option.new(*arguments, **options, &block)
		end
		
		def merge!(options)
			options.each do |option|
				self << option
			end
		end
		
		def << option
			@ordered << option
			option.flags.each do |flag|
				@keyed[flag.prefix] = option
				
				flag.alternatives.each do |alternative|
					@keyed[alternative] = option
				end
			end
			
			if default = option.default
				@defaults[option.key] = option.default
			end
		end
		
		def parse(input, parent = nil, default = nil)
			values = (default || @defaults).dup
			
			while option = @keyed[input.first]
				if result = option.parse(input)
					values[option.key] = result
				end
			end
			
			return values
		end
		
		def to_s
			@ordered.collect(&:to_s).join(' ')
		end
		
		def usage(rows)
			@ordered.each do |option|
				rows << option
			end
		end
	end
end
