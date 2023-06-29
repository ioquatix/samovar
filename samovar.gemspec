# frozen_string_literal: true

require_relative "lib/samovar/version"

Gem::Specification.new do |spec|
	spec.name = "samovar"
	spec.version = Samovar::VERSION
	
	spec.summary = "Samovar is a flexible option parser excellent support for sub-commands and help documentation."
	spec.authors = ["Samuel Williams", "Gabriel Mazetto"]
	spec.license = "MIT"
	
	spec.cert_chain  = ['release.cert']
	spec.signing_key = File.expand_path('~/.gem/release.pem')
	
	spec.homepage = "https://github.com/ioquatix/samovar"
	
	spec.metadata = {
		"funding_uri" => "https://github.com/sponsors/ioquatix/",
	}
	
	spec.files = Dir.glob(['{lib,spec}/**/*', '*.md'], File::FNM_DOTMATCH, base: __dir__)
	
	spec.add_dependency "console", "~> 1.0"
	spec.add_dependency "mapping", "~> 1.0"
	
	spec.add_development_dependency "bundler"
	spec.add_development_dependency "covered"
	spec.add_development_dependency "sus"
end
