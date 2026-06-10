# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2025, by Samuel Williams.

require "samovar/flags"

describe Samovar::Flags do
	let(:flags) {subject.new("-f/--flag")}
	
	it "can count flags" do
		expect(flags.count).to be == 1
	end
	
	it "returns nil when no match" do
		result = flags.parse(["--other"])
		expect(result).to be_nil
	end
end

describe Samovar::BooleanFlag do
	let(:flag) {Samovar::Flag.parse("--[no]-color")}
	
	it "can check prefix" do
		expect(flag.prefix?("--color")).to be == true
		expect(flag.prefix?("--no-color")).to be == true
		expect(flag.prefix?("--other")).to be == false
	end
	
	it "ignores tokens that do not match the prefix" do
		input = ["--other=true"]
		expect(flag.parse(input)).to be_nil
		expect(input).to be == ["--other=true"]
	end
end

describe Samovar::ValueFlag do
	let(:flag) {Samovar::Flag.parse("--config <path>")}
	
	it "ignores tokens that do not match the prefix" do
		input = ["--other=value"]
		expect(flag.parse(input)).to be_nil
		expect(input).to be == ["--other=value"]
	end
end
