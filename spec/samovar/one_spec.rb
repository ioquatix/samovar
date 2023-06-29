# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2019-2023, by Samuel Williams.

require 'samovar/many'

RSpec.describe Samovar::One do
	let(:default) {"1"}
	let(:input) {["2", "3", "4"]}
	
	subject{described_class.new(:thing, "a thing", default: default)}
	
	it "has string representation" do
		expect(subject.to_s).to be == "<thing>"
	end
	
	it "should have default" do
		expect(subject.default).to be == default
	end
	
	it "should use default" do
		expect(subject.parse([])).to be == default
	end
	
	it "should use specified default" do
		expect(subject.parse([], nil, "2")).to be == "2"
	end
	
	it "should not use default if input specified" do
		expect(subject.parse(input)).to be == "2"
		expect(input).to be == ["3", "4"]
	end
end
