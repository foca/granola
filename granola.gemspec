require "./lib/granola/version"

Gem::Specification.new do |s|
  s.name        = "granola"
  s.licenses    = ["MIT"]
  s.version     = Granola::VERSION
  s.summary     = "Granola: JSON Serializers for your app."
  s.description = "Granola is a very simple and fast library to turn your models to JSON"
  s.authors     = ["Nicolas Sanguinetti"]
  s.email       = ["contacto@nicolassanguinetti.info"]
  s.homepage    = "http://github.com/foca/granola"

  s.files = Dir[
    "LICENSE",
    "README.md",
    "lib/granola.rb",
    "lib/granola/serializer.rb",
    "lib/granola/rendering.rb",
    "lib/granola/util.rb",
    "lib/granola/rack.rb",
    "lib/granola/version.rb",
  ]

  s.add_development_dependency "cutest", "~> 1.2"
  s.add_development_dependency "rack", "~> 2.5"
end

