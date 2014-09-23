require "multi_json"
require "granola/version"

module Granola
  class Serializer
    attr_reader :object

    def self.list(ary)
      List.new(ary, self)
    end

    def initialize(object)
      @object = object
    end

    def attributes
      fail NotImplementedError
    end

    def to_json(**options)
      MultiJson.dump(attributes, options)
    end
  end

  class List < Serializer
    attr_reader :item_serializer

    def initialize(list, serializer)
      @item_serializer = serializer
      @list = list.map { |obj| serializer.new(obj) }
    end

    def attributes
      @list.map(&:attributes)
    end
  end
end
