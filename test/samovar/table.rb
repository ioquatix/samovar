# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2019-2023, by Samuel Williams.

require 'samovar/table'
require 'samovar/options'

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
end
