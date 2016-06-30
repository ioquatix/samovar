
require 'samovar'
require 'stringio'

module Command
	class Coerce < Samovar::Command
		options do
			option '--things <array>', "A list of things" do |input|
				input.split(/\s*,\s*/)
			end
		end
	end
end

describe Samovar::Command do
	it "should use default value" do
		top = Command::Coerce.parse(['--things', 'a,b,c'])
		expect(top.options[:things]).to be == ['a', 'b', 'c']
	end
end
