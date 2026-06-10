# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2016-2025, by Samuel Williams.

source "https://rubygems.org"

gemspec

group :maintenance, optional: true do
	gem "bake-modernize"
	gem "bake-gem"
	gem "bake-releases"
	
	gem "agent-context"
	
	gem "utopia-project"
end

group :test do
	gem "covered"
	gem "sus"
	# `decode` depends on `rbs`, whose native extension fails to build on non-MRI
	# runtimes (e.g. JRuby). It's only used for documentation coverage, which runs on MRI.
	gem "decode", platforms: :mri
	
	gem "rubocop"
	gem "rubocop-md"
	gem "rubocop-socketry"
	
	gem "bake-test"
	gem "bake-test-external"
end
