
require 'samovar'
require 'stringio'

module Samovar::NestedSpec
	class InnerA < Samovar::Command
	end
	
	class InnerB < Samovar::Command
		options do
			option '--help'
		end
	end
	
	class InnerC < InnerB
		options do
			option '--frobulate'
		end
	end
	
	class Outer < Samovar::Command
		options do
			option '--help'
		end
		
		nested '<command>', {
			'inner-a' => InnerA,
			'inner-b' => InnerB,
			'inner-c' => InnerC,
		}, default: 'inner-b'
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
		
		it "can parse derived options" do
			outer = Outer['inner-c', '--help']
			expect(outer.command).to be_kind_of(InnerC)
			expect(outer.command.options).to include(help: true)
		end
		
		xit "should parse help option at outer level" do
			outer = Outer['inner-a', '--help']
			expect(outer.options[:help]).to_be truthy
		end
	end
end
