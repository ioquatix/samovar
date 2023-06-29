# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2017-2023, by Samuel Williams.

require 'samovar'

RSpec.describe Samovar::Nested do
	let(:commands) do
		{
			'inner-a' => Class.new(Samovar::Command),
			'inner-b' => Class.new(Samovar::Command),
		}
	end
	
	let(:default) {'inner-a'}
	let(:input) {['inner-a']}
	subject{described_class.new(:command, commands, default: default)}
	
	it "has string representation" do
		expect(subject.to_s).to be == "<command>"
	end
	
	it "should have default" do
		expect(subject.default).to be == default
	end
	
	it "should use default" do
		expect(subject.parse([])).to be_kind_of commands[default]
	end
	
	it "should use specified default" do
		command = commands['inner-b'].new
		
		expect(subject.parse([], nil, command)).to be command
	end
	
	it "should not use default if input specified" do
		expect(subject.parse(input)).to be_kind_of commands['inner-a']
	end
end

module Samovar::NestedSpec
	class InnerA < Samovar::Command
		options
	end
	
	class InnerB < InnerA
		options do
			option '--help', "Do you need it?"
		end
	end
	
	class InnerC < InnerB
		options do
			option '--frobulate', "Zork is waiting for you."
		end
	end
	
	class Outer < Samovar::Command
		options do
		end

		nested :command, {
			'inner-a' => InnerA,
			'inner-b' => InnerB,
			'inner-c' => InnerC,
		}, default: 'inner-b'
	end

	RSpec.describe Samovar::Nested do
		it "should select default nested command" do
			outer = Outer[]
			expect(outer.command).to be_kind_of(InnerB)
			
			outer.print_usage
		end

		it "should select explicitly named nested command" do
			outer = Outer['inner-a']
			expect(outer.command).to be_kind_of(InnerA)
		end

		it "can parse derived options" do
			outer = Outer['inner-c', '--help']
			expect(outer.command).to be_kind_of(InnerC)
			expect(outer.command.options).to include(help: true)
			expect(outer.command.parent).to be outer
		end

		xit "should parse help option at outer level" do
			outer = Outer['inner-a', '--help']
			expect(outer.options[:help]).to_be truthy
		end
	end
end
