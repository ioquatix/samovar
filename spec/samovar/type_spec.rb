
require 'samovar'
require 'stringio'

module Command
	class Coerce < Samovar::Command
		options do
			option '--things <array>', "A list of things" do |input|
				input.split(/\s*,\s*/)
			end
			
			option '--count <integer>', "A number to count", type: Integer
		end
	end
end

describe Samovar::Command do
	it "should coerce to array" do
		top = Command::Coerce.parse(['--things', 'a,b,c'])
		expect(top.options[:things]).to be == ['a', 'b', 'c']
	end
	
	it "should coerce to integer" do
		top = Command::Coerce.parse(['--count', '10'])
		expect(top.options[:count]).to be == 10
	end
end
