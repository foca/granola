require "granola/helper"

include Granola::Helper

class CustomSerializer < Granola::Serializer
  def serialized
    { "name" => object.name }
  end
end

module Namespaced
  class Model
  end

  class ModelSerializer < Granola::Serializer
  end
end

setup do
  Person.new("John Doe", 25, Time.at(987654321))
end

test "infers the serializer correctly" do |person|
  klass = Granola::Helper.serializer_class_for(person)
  assert_equal PersonSerializer, klass

  klass = Granola::Helper.serializer_class_for([person])
  assert_equal PersonSerializer, klass

  klass = Granola::Helper.serializer_class_for([])
  assert_equal Granola::Helper::PrimitiveTypesSerializer, klass

  klass = Granola::Helper.serializer_class_for(Namespaced::Model.new)
  assert_equal Namespaced::ModelSerializer, klass
end

test "#serializer_for infers the serializer class" do |person|
  serializer = serializer_for(person)
  assert serializer.is_a?(PersonSerializer)
end

test "#serializer_for can take a specific serializer to use" do |person|
  serializer = serializer_for(person, with: CustomSerializer)
  assert serializer.is_a?(CustomSerializer)
end

test "#serializer_for handles lists automatically" do |person|
  serializer = serializer_for([person])
  assert serializer.is_a?(Granola::List)
  assert_equal PersonSerializer, serializer.item_serializer
end

test "#serializer_for handles empty lists automatically" do
  serializer = serializer_for([])
  assert serializer.is_a?(Granola::List)
  assert_equal \
    Granola::Helper::PrimitiveTypesSerializer, serializer.item_serializer
end

test "#serializer_for accepts a Granola::Serializer" do |person|
  serializer = PersonSerializer.new(person)
  assert_equal serializer, serializer_for(serializer)
end

test "#serializer_for ignores `with` when passed a serializer" do |person|
  expected = PersonSerializer.new(person)
  actual = serializer_for(expected, with: CustomSerializer)
  assert_equal expected, actual
  assert PersonSerializer === actual
end

test "#serializer_for correctly serializes primitive types" do
  [nil, true, false, 10, 5.0, "foo"].each do |primitive_type|
    serializer = serializer_for(primitive_type)
    assert_equal primitive_type, serializer.serialized
  end
end
