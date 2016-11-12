require "benchmark/ips"
require "granola"
require "oj"
require "multi_json"

# This benchmark compares serializing a relatively trivial structure using both
# Yajl via MultiJson and plain Yajl.

User = Struct.new(:name, :age)

class UserSerializer < Granola::Serializer
  def data
    { "name" => object.name, "age" => object.age }
  end
end

SERIALIZER = UserSerializer.new(User.new("John Doe", 30))
MultiJson.use :oj

Benchmark.ips do |b|
  b.report("plain") do
    Granola.render :json, via: Oj.method(:dump),
                          content_type: "application/json"
    SERIALIZER.to_json
  end

  b.report("multi_json") do
    Granola.render :json, via: MultiJson.method(:dump),
                          content_type: "application/json"
    SERIALIZER.to_json
  end

  b.compare!
end
