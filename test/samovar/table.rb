# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2019-2025, by Samuel Williams.

require "samovar/table"
require "samovar/options"

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
end

