
require 'samovar'
require 'stringio'

module Samovar::NestedSpec
	class InnerA < Samovar::Command
	end
	
	class InnerB < Samovar::Command
	end
	
	class Outer < Samovar::Command
		nested '<command>',
			'inner-a' => InnerA,
			'inner-b' => InnerB,
			default: 'inner-b'
	end
	
	RSpec.describe Samovar::Nested do
		it "should select default nested command" do
			outer = Outer[]
			expect(outer.command).to be_kind_of(InnerB)
		end
		
		it "should select explicitly named nested command" do
			outer = Outer['inner-a']
			expect(outer.command).to be_kind_of(InnerA)
		end
	end
end
