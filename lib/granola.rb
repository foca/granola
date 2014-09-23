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
      {}
    end

    def cache_key
    end

    def last_modified
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

    def cache_key
      all = @list.map(&:cache_key).compact
      all.join("-") if all.any?
    end

    def last_modified
      @list.map(&:last_modified).compact.sort.last
    end
  end
end
