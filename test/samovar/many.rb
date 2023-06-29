# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2019-2023, by Samuel Williams.

require 'samovar/many'

describe Samovar::Many do
	let(:default) {["1", "2", "3"]}
	let(:input) {["2", "3", "--else"]}
	
	let(:many) {subject.new(:items, "some items", default: default)}
	
	it "has string representation" do
		expect(many.to_s).to be == "<items...>"
	end
	
	it "should have default" do
		expect(many.default).to be == default
	end
	
	it "should use default" do
		expect(many.parse([])).to be == default
	end
	
	it "should use specified default" do
		expect(many.parse([], nil, ["2"])).to be == ["2"]
	end
	
	it "should not use default if input specified" do
		expect(many.parse(input)).to be == ["2", "3"]
		expect(input).to be == ["--else"]
	end
end
