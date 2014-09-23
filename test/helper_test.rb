include Granola::Helper

class CustomSerializer < Granola::Serializer
  def attributes
    { "name" => object.name }
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
  assert_equal Granola::Helper::NilClassSerializer, klass
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
  assert_equal Granola::Helper::NilClassSerializer, serializer.item_serializer
end
