module Granola
  # A Serializer describes how to serialize a certain type of object, by
  # declaring the structure of JSON objects.
  class Serializer
    # Public: Get the domain model to serialize.
    attr_reader :object

    # Public: Instantiates a list serializer that wraps around an iterable of
    # objects of the type expected by this serializer class.
    #
    # Example:
    #
    #   serializer = PersonSerializer.list(people)
    #   serializer.to_json
    #
    # Returns a Granola::List.
    def self.list(ary, *args)
      List.new(ary, *args, with: self)
    end

    # Public: Initialize the serializer with a given object.
    #
    # object - The domain model that we want to serialize.
    def initialize(object)
      @object = object
    end

    # Public: Returns a primitive Object that can be serialized into JSON,
    # meaning one of `nil`, `true`, `false`, a String, a Numeric, an Array of
    # primitive objects, or a Hash with String keys and primitive objects as
    # values.
    #
    # Raises NotImplementedError unless you override in subclasses.
    def data
      fail NotImplementedError
    end
  end

  # Internal: The List serializer provides an interface for serializing lists of
  # objects, wrapping around a specific serializer. The preferred API for this
  # is to use `Granola::Serializer.list`.
  #
  # Example:
  #
  #   serializer = Granola::List.new(people, with: PersonSerializer)
  #   serializer.to_json
  #
  # You should use Serializer.list instead of this class.
  class List < Serializer
    # Internal: Get the serializer class to use for each item of the list.
    attr_reader :item_serializer

    # Public: Instantiate a new list serializer.
    #
    # list  - An Array-like structure.
    # *args - Any other arguments that the item serializer takes.
    #
    # Keywords:
    #   with: The subclass of Granola::Serializer to use when serializing
    #         specific elements in the list.
    def initialize(list, *args, with: serializer)
      @item_serializer = with
      @list = list.map { |obj| @item_serializer.new(obj, *args) }
    end

    # Public: Returns an Array of Hashes that can be serialized into JSON.
    def data
      @list.map(&:data)
    end
  end
end
