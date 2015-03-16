require "granola/serializer"
require "json"

module Granola
  class << self
    # Public: Get/Set a Proc that takes an Object and a Hash of options and
    # returns a JSON String.
    #
    # The default implementation uses the standard library's JSON module, but
    # you're welcome to swap it out.
    #
    # Example:
    #
    #   require "yajl"
    #   Granola.json = ->(obj, **opts) { Yajl::Encoder.encode(obj, opts) }
    attr_accessor :json
  end

  if defined?(MultiJson)
    self.json = MultiJson.method(:dump)
  else
    self.json = JSON.method(:generate)
  end

  class Serializer
    MIME_TYPES[:json] = "application/json".freeze

    # Public: Generate the JSON String.
    #
    # **options - Any options to be passed to the `Granola.json` Proc.
    #
    # Returns a String.
    def to_json(**options)
      Granola.json.(data, options)
    end
  end
end
