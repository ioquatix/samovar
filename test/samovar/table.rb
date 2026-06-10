# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2019-2026, by Samuel Williams.

require "samovar/table"
require "samovar/options"
require "samovar/many"
require "samovar/command"

describe Samovar::Table do
	let(:parent) {subject.new}
	let(:table) {subject.new(parent)}
	
	it "can merge options" do
		parent << Samovar::Options.parse
		table << Samovar::Options.parse do
			option "--help", "Print help information."
		end
		
		table.merged
		parent.merged
		
		expect(parent[:options]).to be(:empty?)
	end
	
	with "freeze" do
		it "can freeze table" do
			table << Samovar::Options.parse
			table.freeze
			
			expect(table).to be(:frozen?)
		end
		
		it "returns self if already frozen" do
			table.freeze
			result = table.freeze
			
			expect(result).to be_equal(table)
		end
	end
	
	with "empty tables" do
		it "detects non-empty table" do
			table << Samovar::Options.parse
			expect(table).not.to be(:empty?)
		end
	end
	
	with "command line without table" do
		let(:minimal_command) do
			Class.new(Samovar::Command) do
				# No table at all
				def self.table
					Samovar::Table.new
				end
			end
		end
		
		it "handles empty table in command_line" do
			# Mock the merged table to return nil
			result = minimal_command.command_line("test")
			expect(result).to be(:include?, "test")
		end
	end
	
	with "options and many values" do
		let(:input) {["-x", "10", "1", "2", "3", "-y"]}
		let(:receiver) {Struct.new(:options, :items).new}
		
		let(:options) do
			Samovar::Options.parse do
				option "-x <value>", "The x factor", default: 2
				option "-y", "Use y axis"
			end
		end
		
		let(:many) {Samovar::Many.new(:items, "some items", default: [])}
		
		let(:table) do
			subject.new.tap do |table|
				table << options
				table << many
			end
		end
		
		it "parses many values and preserves trailing option for later parsing" do
			table.parse(input, receiver)
			
			expect(receiver.options).to have_keys(x: be == "10")
			expect(receiver.items).to be == ["1", "2", "3"]
			expect(input).to be == ["-y"]
		end
	end
end

