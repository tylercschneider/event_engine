require_relative "lib/event_engine/version"

Gem::Specification.new do |spec|
  spec.name        = "event_engine"
  spec.version     = EventEngine::VERSION
  spec.authors     = ["tylercschneider"]
  spec.email       = ["tylercschneider@gmail.com"]
  spec.homepage    = "https://github.com/tylercschneider/event_engine"
  spec.summary     = "Schema-first event pipeline engine for Rails"
  spec.description = "A Rails engine providing schema-first event definitions, outbox pattern persistence, and pluggable transport adapters. Define events with a Ruby DSL, compile to a canonical schema, and publish through Kafka or custom transports."
  spec.license     = "MIT"

  spec.metadata["allowed_push_host"] = "https://rubygems.org"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/tylercschneider/event_engine"
  spec.metadata["changelog_uri"] = "https://github.com/tylercschneider/event_engine/blob/main/CHANGELOG.md"
  spec.metadata["bug_tracker_uri"] = "https://github.com/tylercschneider/event_engine/issues"
  spec.metadata["documentation_uri"] = "https://github.com/tylercschneider/event_engine#readme"

  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.md"]
  end

  spec.add_dependency "rails", ">= 7.1.6"
  spec.add_dependency "activesupport"
end
