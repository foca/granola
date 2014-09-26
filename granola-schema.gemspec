require "./lib/granola/version"

Gem::Specification.new do |s|
  s.name        = "granola-schema"
  s.licenses    = ["MIT"]
  s.version     = Granola::VERSION
  s.summary     = "Granola::Schema adds JSON schema support to Granola"
  s.description = "Handles JSON Schema support for Granola serializers."
  s.authors     = ["Nicolas Sanguinetti"]
  s.email       = ["contacto@nicolassanguinetti.info"]
  s.homepage    = "http://github.com/foca/granola"

  s.files = Dir[
    "LICENSE",
    "README.md",
    "lib/granola/schema.rb",
  ]

  s.add_dependency "granola", "= #{Granola::VERSION}"
  s.add_dependency "json-schema", "~> 2.2"

  s.add_development_dependency "cutest", "~> 1.2"
end
