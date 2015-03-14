require "granola"
require "granola/caching"

Person = Struct.new(:name, :age, :updated_at)

class PersonSerializer < Granola::Serializer
  def serialized
    { "name" => object.name, "age" => object.age }
  end

  def last_modified
    object.updated_at
  end

  def cache_key
    "%s|%s" % [object.name, last_modified.to_i]
  end
end
