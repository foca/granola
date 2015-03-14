require "ostruct"

class OpenStructSerializer < Granola::Serializer
  def serialized
    object.send(:table).each.with_object({}) do |(key, val), hash|
      hash[key.to_s] = val
    end
  end
end

class CustomMIMESerializer < OpenStructSerializer
  def mime_type
    "application/my-app+json"
  end
end

scope do
  setup do
    OpenStruct.new(a: 1, b: 2, c: 3)
  end

  test "serializes the properties" do |object|
    serializer = OpenStructSerializer.new(object)
    assert_equal({ "a" => 1, "b" => 2, "c" => 3 }, serializer.serialized)
  end

  test "converts to json" do |object|
    serializer = OpenStructSerializer.new(object)
    assert_equal %q|{"a":1,"b":2,"c":3}|, serializer.to_json
  end

  test "knows the default MIME type" do |object|
    serializer = OpenStructSerializer.new(object)
    assert_equal "application/json", serializer.mime_type
  end

  test "can define custom mime types" do |object|
    serializer = CustomMIMESerializer.new(object)
    assert_equal "application/my-app+json", serializer.mime_type
  end
end

scope do
  setup do
    [OpenStruct.new(a: 1, b: 2), OpenStruct.new(a: 3, b: 4)]
  end

  test "serializes a list" do |array|
    serializer = OpenStructSerializer.list(array)
    assert_equal %q|[{"a":1,"b":2},{"a":3,"b":4}]|, serializer.to_json
  end
end

scope do
  setup do
    OpenStruct.new(a: 1, b: 2, c: 3)
  end

  test "allows passing options to the json backend" do |object|
    serializer = OpenStructSerializer.new(object)
    assert_equal %q|{"a": 1,"b": 2,"c": 3}|, serializer.to_json(space: " ")
  end
end

scope do
  class MultipleObjectSerializer < Granola::Serializer
    attr_reader :another

    def initialize(object, another)
      super(object)
      @another = another
    end

    def serialized
      { "foo" => object.foo, "bar" => another.bar }
    end
  end

  test "can modify the serializer's initialize method" do
    foo = OpenStruct.new(foo: 1)
    bar = OpenStruct.new(bar: 2)

    serializer = MultipleObjectSerializer.new(foo, bar)
    assert_equal %q|{"foo":1,"bar":2}|, serializer.to_json
  end

  test "can pass multiple arguments even if using a list" do
    foos = [OpenStruct.new(foo: 1), OpenStruct.new(foo: 2)]
    bar = OpenStruct.new(bar: 3)

    serializer = MultipleObjectSerializer.list(foos, bar)
    assert_equal %q|[{"foo":1,"bar":3},{"foo":2,"bar":3}]|, serializer.to_json
  end
end

scope do
  prepare do
    Granola.json = ->(obj, **opts) { "success!" }
  end

  test "serializes with a custom json backend" do
    serializer = OpenStructSerializer.new(OpenStruct.new)
    assert_equal "success!", serializer.to_json
  end
end
