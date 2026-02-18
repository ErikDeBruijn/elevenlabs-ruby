require_relative "lib/eleven_labs/version"

Gem::Specification.new do |spec|
  spec.name = "eleven_labs"
  spec.version = ElevenLabs::VERSION
  spec.authors = ["Erik de Bruijn"]
  spec.email = ["erik@erikdebruijn.nl"]

  spec.summary = "Ruby client for the ElevenLabs text-to-speech API"
  spec.description = "A thin Ruby client for the ElevenLabs API. Generate speech from text and list available voices."
  spec.homepage = "https://github.com/erikdebruijn/elevenlabs-ruby"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 3.1"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = spec.homepage

  spec.files = Dir.glob("lib/**/*") + %w[elevenlabs.gemspec Gemfile]
  spec.require_paths = ["lib"]

  spec.add_dependency "faraday", "~> 2.0"
end
