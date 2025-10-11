# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2019-2025, by Samuel Williams.

require "samovar/split"

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
	
	with "required field" do
		let(:required_split) {subject.new(:arguments, "arguments", required: true)}
		
		it "raises error when required field is missing" do
			expect do
				required_split.parse([])
			end.to raise_exception(Samovar::MissingValueError)
		end
		
		it "includes required in usage" do
			usage = required_split.to_a
			expect(usage.join(" ")).to be(:include?, "required")
		end
	end
	
	with "default value" do
		it "includes default in usage" do
			usage = split.to_a
			expect(usage.join(" ")).to be(:include?, "default")
		end
	end
end

