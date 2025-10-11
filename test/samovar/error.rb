# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2025, by Samuel Williams.

require "samovar"

describe Samovar::InvalidInputError do
	let(:command) {Samovar::Command.new}
	
	it "can create an error with invalid input" do
		error = Samovar::InvalidInputError.new(command, ["--unknown-flag"])
		
		expect(error.command).to be == command
		expect(error.input).to be == ["--unknown-flag"]
		expect(error.token).to be == "--unknown-flag"
		expect(error.message).to be(:include?, "--unknown-flag")
	end
	
	it "can detect help flag" do
		error = Samovar::InvalidInputError.new(command, ["--help"])
		
		expect(error.help?).to be == true
	end
	
	it "can detect non-help flag" do
		error = Samovar::InvalidInputError.new(command, ["--other"])
		
		expect(error.help?).to be == false
	end
end

describe Samovar::MissingValueError do
	let(:command) {Samovar::Command.new}
	let(:field) {:project_name}
	
	it "can create an error for missing value" do
		error = Samovar::MissingValueError.new(command, field)
		
		expect(error.command).to be == command
		expect(error.field).to be == field
		expect(error.message).to be(:include?, "project_name")
	end
end
