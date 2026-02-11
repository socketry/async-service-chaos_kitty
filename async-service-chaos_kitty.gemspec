# frozen_string_literal: true

require_relative "lib/async/service/chaos_kitty/version"

Gem::Specification.new do |spec|
	spec.name = "async-service-chaos_kitty"
	spec.version = Async::Service::ChaosKitty::VERSION
	
	spec.summary = "A chaos monkey system for testing service resilience with cat-themed chaos operations."
	spec.authors = ["Samuel Williams"]
	spec.license = "MIT"
	
	spec.homepage = "https://github.com/socketry/async-service-chaos_kitty"
	
	spec.metadata = {
		"documentation_uri" => "https://socketry.github.io/async-service-chaos_kitty/",
		"source_code_uri" => "https://github.com/socketry/async-service-chaos_kitty.git",
	}
	
	spec.files = Dir.glob(["{lib}/**/*", "*.md"], File::FNM_DOTMATCH, base: __dir__)
	
	spec.required_ruby_version = ">= 3.2"
	
	spec.add_dependency "async-bus"
	spec.add_dependency "async-service", "~> 0.15"
	spec.add_dependency "io-endpoint"
end
