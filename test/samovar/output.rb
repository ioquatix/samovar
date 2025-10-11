# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2025, by Samuel Williams.

require "samovar"
require "samovar/output/rows"
require "samovar/output/header"

describe Samovar::Output::Rows do
	let(:rows) {subject.new}
	
	it "can check if empty" do
		expect(rows).to be(:empty?)
	end
	
	it "can get first row" do
		rows << Samovar::Option.new("-x", "X value")
		expect(rows.first).not.to be_nil
	end
	
	it "can get last row" do
		rows << Samovar::Option.new("-x", "X value")
		rows << Samovar::Option.new("-y", "Y value")
		expect(rows.last).not.to be_nil
	end
end

describe Samovar::Output::Header do
	let(:command_class) do
		Class.new(Samovar::Command) do
			self.description = "Test command"
			
			options do
				option "--help", "Show help"
			end
		end
	end
	
	it "can align header" do
		header = Samovar::Output::Header.new("test", command_class)
		result = header.align(nil)
		
		expect(result).to be(:include?, "test")
	end
end
