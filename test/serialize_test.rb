require "ostruct"

class OpenStructSerializer < Granola::Serializer
  def attributes
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
    assert_equal({ "a" => 1, "b" => 2, "c" => 3 }, serializer.attributes)
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
