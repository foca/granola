# frozen_string_literal: true
require "granola/serializer"

module Granola
  module Util
    class << self
      # Public: Get/Set the mechanism used to look up constants by name. This
      # should be a callable that takes a String with a constant's name and
      # converts this to a Serializer class, or fails with NameError.
      #
      # Example:
      #
      #   # Find serializers under Serializers::Foo instead of FooSerializer.
      #   Granola::Util.constant_lookup = ->(name) do
      #     Serializers.const_get(name.sub(/Serializer$/, ""))
      #   end
      attr_accessor :constant_lookup
    end

    self.constant_lookup = Object.method(:const_get)

    # Public: Returns the serializer object for rendering a specific object. The
    # class will attempt to be inferred based on the class of the passed object,
    # but a specific serializer can be passed via a keyword argument `with`.
    #
    # object - The Object to serialize.
    #
    # Keywords
    #   with: A specific serializer class to use. If this is `nil`,
    #         `Util.serializer_class_for` will be used to infer the serializer
    #         class. This is ignored if `object` is already a Serializer.
    #
    # Raises NameError if no specific serializer is provided and we fail to
    # infer one for this object.
    #
    # Returns an instance of a Granola::Serializer subclass.
    def self.serializer_for(object, with: nil)
      return object if Granola::Serializer === object
      serializer_class = with || serializer_class_for(object)
      method = object.respond_to?(:to_ary) ? :list : :new
      serializer_class.send(method, object)
    end

    # Internal: Infers the name of a serializer based on the class of the passed
    # object. The pattern is the Object's class + "Serializer". So
    # `PersonSerializer` for `Person`.
    #
    # object - An object of a class with a matching serializer.
    #
    # Raises NameError if no matching class exists.
    # Returns a Class.
    def self.serializer_class_for(object)
      object = object.respond_to?(:to_ary) ? object.to_ary[0] : object

      case object
      when Hash, NilClass, TrueClass, FalseClass, Numeric, String
        PrimitiveTypesSerializer
      else
        name = object.class.name
        constant_lookup.call("%sSerializer" % name)
      end
    end

    # Internal: Serializer that transparently handles rendering primitive types.
    class PrimitiveTypesSerializer < Granola::Serializer
      def data
        object
      end
    end
  end
end
