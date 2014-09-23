require "granola"

module Granola
  module Caching
    def cache_key
    end

    def last_modified
    end
  end

  class Serializer
    include Caching
  end

  class List < Serializer
    def cache_key
      all = @list.map(&:cache_key).compact
      all.join("-") if all.any?
    end

    def last_modified
      @list.map(&:last_modified).compact.sort.last
    end
  end
end
