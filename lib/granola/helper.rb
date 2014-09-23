require "granola"

module Granola::Helper
  def serializer_for(object, with: nil)
    serializer_class = with || Granola::Helper.serializer_class_for(object)
    method = object.respond_to?(:to_ary) ? :list : :new
    serializer_class.send(method, object)
  end

  def self.serializer_class_for(object)
    object = object.respond_to?(:to_ary) ? object.to_ary.fetch(0, nil) : object
    const_get("#{object.class.name}Serializer")
  end

  class NilClassSerializer < Granola::Serializer
    def attributes
      {}
    end
  end
end
