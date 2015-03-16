require "json-schema"
require "granola"

module Granola
  class Serializer
    # This module adds support for JSON Schema to Granola serializers. You
    # should define the schema for each serializer
    module Schema
      def self.included(base)
        base.extend ClassMethods
      end

      module ClassMethods
        # Public: The schema definition for entities emitted by this serializer.
        #
        # Returns a Hash that complies to JSON schema.
        def schema
          fail NotImplementedError
        end
      end

      # Public: Validate this serializer against it's own schema.
      #
      # Returns Boolean indicating whether it's valid. In case it's not, it
      # populates the `#validation_errors` Array.
      def valid?
        validation_errors.clear
        validation_errors.concat(
          JSON::Validator.fully_validate(self.class.schema, serialized)
        )
        validation_errors.empty?
      end

      # Public: List any errors that arose from validating this against its
      # schema.
      #
      # See #valid?
      #
      # Returns an Array.
      def validation_errors
        @validation_errors ||= []
      end
    end

    include Schema
  end

  # Public: Schema serializer to render your JSON schemas.
  #
  # Example:
  #
  #   serializer = SchemaSerializer.new(PersonSerializer.schema)
  #   serializer.to_json
  class SchemaSerializer < Serializer
    MIME_TYPES[:json] = "application/schema+json".freeze

    def serialized
      {
        "$schema".freeze => "http://json-schema.org/schema#".freeze,
        "type".freeze => "object".freeze
      }.merge(object)
    end
  end
end
