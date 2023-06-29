# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2019-2023, by Samuel Williams.

require 'samovar/split'

describe Samovar::Split do
	let(:default) {["1", "2", "3"]}
	let(:input) {["2", "--", "3"]}
	
	let(:split) {subject.new(:arguments, "arguments", default: default)}
	
	it "has string representation" do
		expect(split.to_s).to be == "-- <arguments...>"
	end
	
	it "should have default" do
		expect(split.default).to be == default
	end
	
	it "should use default" do
		expect(split.parse([])).to be == default
	end
	
	it "should use specified default" do
		expect(split.parse([], nil, ["2"])).to be == ["2"]
	end
	
	it "should not use default if input specified" do
		expect(split.parse(input)).to be == ["3"]
		expect(input).to be == ["2"]
	end
end
