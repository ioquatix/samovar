# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2016-2023, by Samuel Williams.

module Samovar
	class Flags
		def initialize(text)
			@text = text
			
			@ordered = text.split(/\s+\|\s+/).map{|part| Flag.new(part)}
		end
		
		def each(&block)
			@ordered.each(&block)
		end
		
		def first
			@ordered.first
		end
		
		# Whether or not this flag should have a true/false value if not specified otherwise.
		def boolean?
			@ordered.count == 1 and @ordered.first.value.nil?
		end
		
		def count
			return @ordered.count
		end
		
		def to_s
			'[' + @ordered.join(' | ') + ']'
		end
		
		def parse(input)
			@ordered.each do |flag|
				if result = flag.parse(input)
					return result
				end
			end
			
			return nil
		end
	end
	
	class Flag
		def initialize(text)
			@text = text
			
			if text =~ /(.*?)\s(\<.*?\>)/
				@prefix = $1
				@value = $2
			else
				@prefix = @text
				@value = nil
			end
			
			*@alternatives, @prefix = @prefix.split('/')
		end
		
		attr :text
		attr :prefix
		attr :alternatives
		attr :value
		
		def to_s
			@text
		end
		
		def prefix?(token)
			@prefix == token or @alternatives.include?(token)
		end
		
		def key
			@key ||= @prefix.sub(/^-*/, '').gsub('-', '_').to_sym
		end
		
		def parse(input)
			if prefix?(input.first)
				if @value
					input.shift(2).last
				else
					input.shift; key
				end
			end
		end
	end
end
