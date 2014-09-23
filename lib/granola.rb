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
    def initialize(list, serializer)
      @list = list.map { |obj| serializer.new(obj) }
    end

    def attributes
      @list.map(&:attributes)
    end
  end
end
