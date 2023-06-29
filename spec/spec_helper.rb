# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2016-2023, by Samuel Williams.

require 'covered/rspec'

RSpec.configure do |config|
	config.disable_monkey_patching!
	
	# Enable flags like --only-failures and --next-failure
	config.example_status_persistence_file_path = ".rspec_status"

	config.expect_with :rspec do |c|
		c.syntax = :expect
	end
end
