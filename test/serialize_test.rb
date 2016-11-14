require "ostruct"

class OpenStructSerializer < Granola::Serializer
  def data
    object.send(:table).each.with_object({}) do |(key, val), hash|
      hash[key.to_s] = val
    end
  end
end

scope do
  setup do
    OpenStruct.new(a: 1, b: 2, c: 3)
  end

  test "serializes the properties" do |object|
    serializer = OpenStructSerializer.new(object)
    assert_equal({ "a" => 1, "b" => 2, "c" => 3 }, serializer.data)
  end

  test "converts to json" do |object|
    serializer = OpenStructSerializer.new(object)
    assert_equal %q|{"a":1,"b":2,"c":3}|, serializer.to_json
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

    def data
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
