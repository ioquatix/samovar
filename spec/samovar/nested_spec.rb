# Copyright, 2019, by Samuel G. D. Williams. <http://www.codeotaku.com>
# 
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
# 
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
# 
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.

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
