# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2016-2023, by Samuel Williams.

module Samovar
	class Flags
		def initialize(text)
			@text = text
			
			@ordered = text.split(/\s+\|\s+/).map{|part| Flag.parse(part)}
		end
		
		def each(&block)
			@ordered.each(&block)
		end
		
		def first
			@ordered.first
		end
		
		# Whether or not this flag should have a true/false value if not specified otherwise.
		def boolean?
			@ordered.count == 1 and @ordered.first.boolean?
		end
		
		def count
			return @ordered.count
		end
		
		def to_s
			"[#{@ordered.join(' | ')}]"
		end
		
		def parse(input)
			@ordered.each do |flag|
				result = flag.parse(input)
				if result != nil
					return result
				end
			end
			
			return nil
		end
	end
	
	class Flag
		def self.parse(text)
			if text =~ /(.*?)\s(\<.*?\>)/
				ValueFlag.new(text, $1, $2)
			elsif text =~ /--\[no\]-(.*?)$/
				BooleanFlag.new(text, "--#{$1}")
			else
				ValueFlag.new(text, text, nil)
			end
		end
		
		def initialize(text, prefix, alternatives = nil)
			@text = text
			@prefix = prefix
			@alternatives = alternatives
		end
		
		attr :text
		attr :prefix
		attr :alternatives
		
		def to_s
			@text
		end
		
		def key
			@key ||= @prefix.sub(/^-*/, '').gsub('-', '_').to_sym
		end
		
		def boolean?
			false
		end
	end
	
	class ValueFlag < Flag
		def initialize(text, prefix, value)
			super(text, prefix)
			
			@value = value
			
			*@alternatives, @prefix = @prefix.split('/')
		end
		
		attr :alternatives
		attr :value
		
		def boolean?
			@value.nil?
		end
		
		def prefix?(token)
			@prefix == token or @alternatives.include?(token)
		end
		
		def parse(input)
			if prefix?(input.first)
				if @value
					return input.shift(2).last
				else
					input.shift
					return key
				end
			end
		end
	end
	
	class BooleanFlag < Flag
		def initialize(text, prefix, value = nil)
			super(text, prefix)
			
			@value = value
			
			@negated = @prefix.sub(/^--/, '--no-')
			@alternatives = [@negated]
		end
		
		def prefix?(token)
			@prefix == token or @negated == token
		end
		
		def parse(input)
			if input.first == @prefix
				input.shift
				return true
			elsif input.first == @negated
				input.shift
				return false
			end
		end
	end
end
