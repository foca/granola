require "granola"

module Granola::Util
  # Public: Returns the serializer object for rendering a specific object. The
  # class will attempt to be inferred based on the class of the passed object,
  # but a specific serializer can be passed via a keyword argument `with`.
  #
  # object - The Object to serialize.
  #
  # Keywords
  #   with: A specific serializer class to use. If this is `nil`,
  #         `Util.serializer_class_for` will be used to infer the serializer
  #         class. This is ignored if `object` is already a Granola::Serializer.
  #
  # Raises NameError if no specific serializer is provided and we fail to infer
  #   one for this object.
  # Returns an instance of a Granola::Serializer subclass.
  def self.serializer_for(object, with: nil)
    return object if Granola::Serializer === object
    serializer_class = with || serializer_class_for(object)
    method = object.respond_to?(:to_ary) ? :list : :new
    serializer_class.send(method, object)
  end

  # Internal: Infers the name of a serialized based on the class of the passed
  # object. The pattern is the Object's class + "Serializer". So
  # `PersonSerializer` for `Person`.
  #
  # object - An object of a class with a matching serializer.
  #
  # Raises NameError if no matching class exists.
  # Returns a Class.
  def self.serializer_class_for(object)
    object = object.respond_to?(:to_ary) ? object.to_ary.fetch(0, nil) : object
    name = object.class.name
    Object.const_get("%sSerializer" % name)
  rescue NameError
    case object
    when NilClass, TrueClass, FalseClass, Numeric, String
      PrimitiveTypesSerializer
    else
      raise
    end
  end

  # Internal: Null serializer that transparently handles rendering `nil` in case
  # it's passed.
  class PrimitiveTypesSerializer < Granola::Serializer
    def serialized
      object
    end
  end
end