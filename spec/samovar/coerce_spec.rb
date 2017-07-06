
require 'samovar'
require 'stringio'

module Samovar::CoerceSpec
	class Coerce < Samovar::Command
		options do
			option '--things <array>', "A list of things" do |input|
				input.split(/\s*,\s*/)
			end
			
			option '--count <integer>', "A number to count", type: Integer
		end
	end

	RSpec.describe Samovar::Command do
		it "should coerce to array" do
			top = Coerce['--things', 'a,b,c']
			expect(top.options[:things]).to be == ['a', 'b', 'c']
		end
		
		it "should coerce to integer" do
			top = Coerce['--count', '10']
			expect(top.options[:count]).to be == 10
		end
	end
end
