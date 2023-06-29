# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2019-2023, by Samuel Williams.

require 'samovar/many'

describe Samovar::One do
	let(:default) {"1"}
	let(:input) {["2", "3", "4"]}
	
	let(:one) {subject.new(:thing, "a thing", default: default)}
	
	it "has string representation" do
		expect(one.to_s).to be == "<thing>"
	end
	
	it "should have default" do
		expect(one.default).to be == default
	end
	
	it "should use default" do
		expect(one.parse([])).to be == default
	end
	
	it "should use specified default" do
		expect(one.parse([], nil, "2")).to be == "2"
	end
	
	it "should not use default if input specified" do
		expect(one.parse(input)).to be == "2"
		expect(input).to be == ["3", "4"]
	end
end
