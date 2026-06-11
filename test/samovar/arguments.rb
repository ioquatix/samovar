# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2026, by Samuel Williams.

require "samovar/arguments"

describe Samovar::Arguments do
	it "leaves unrelated tokens unchanged" do
		arguments = Samovar::Arguments.transform(["--foo=bar", "--other", "value"], keys: ["--config"])
		
		expect(arguments).to be == ["--foo=bar", "--other", "value"]
	end
	
	it "rewrites selected assignment tokens" do
		arguments = Samovar::Arguments.transform(["--config=path"], keys: ["--config"])
		
		expect(arguments).to be == ["--config", "path"]
	end
	
	it "supports multiple selected keys" do
		arguments = Samovar::Arguments.transform(["--config=path", "--path=file"], keys: ["--config", "--path"])
		
		expect(arguments).to be == ["--config", "path", "--path", "file"]
	end
end