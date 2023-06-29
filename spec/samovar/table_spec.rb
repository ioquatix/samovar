# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2019-2023, by Samuel Williams.

require 'samovar/table'
require 'samovar/options'

RSpec.describe Samovar::Table do
	let(:parent) {described_class.new}
	subject{described_class.new(parent)}
	
	it "can merge options" do
		parent << Samovar::Options.parse
		subject << Samovar::Options.parse do
			option "--help", "Print help information."
		end
		
		subject.merged
		parent.merged
		
		expect(parent[:options]).to be_empty
	end
end
