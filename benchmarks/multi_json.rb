require "benchmark"
require "granola"
require "yajl"
require "multi_json"

# This benchmark compares serializing a relatively trivial structure using both
# Yajl via MultiJson and plain Yajl.

User = Struct.new(:name, :age)

class UserSerializer < Granola::Serializer
  def serialized
    { "name" => object.name, "age" => object.age }
  end
end

SERIALIZER = UserSerializer.new(User.new("John Doe", 30))

Benchmark.bmbm do |b|
  b.report("plain") do
    Granola.json = Yajl::Encoder.method(:encode)
    10_1000.times { SERIALIZER.to_json }
  end

  b.report("multi_json") do
    MultiJson.use :yajl
    Granola.json = MultiJson.method(:dump)
    10_1000.times { SERIALIZER.to_json }
  end
end
