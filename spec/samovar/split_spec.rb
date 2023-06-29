# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2019-2023, by Samuel Williams.

require 'samovar/split'

RSpec.describe Samovar::Split do
	let(:default) {["1", "2", "3"]}
	let(:input) {["2", "--", "3"]}
	
	subject{described_class.new(:arguments, "arguments", default: default)}
	
	it "has string representation" do
		expect(subject.to_s).to be == "-- <arguments...>"
	end
	
	it "should have default" do
		expect(subject.default).to be == default
	end
	
	it "should use default" do
		expect(subject.parse([])).to be == default
	end
	
	it "should use specified default" do
		expect(subject.parse([], nil, ["2"])).to be == ["2"]
	end
	
	it "should not use default if input specified" do
		expect(subject.parse(input)).to be == ["3"]
		expect(input).to be == ["2"]
	end
end
