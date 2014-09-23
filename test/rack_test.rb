require "rack/response"

class CustomSerializer < Granola::Serializer
  def attributes
    { "name" => object.name }
  end
end

class Context
  include Granola::Rack

  attr_reader :env
  attr_reader :res

  def initialize(env = {})
    @env = env
    @res = Rack::Response.new
  end
end

prepare do
  @person = Person.new("John Doe", 25, Time.at(987654321))
end

setup { Context.new }

test "infers the serializer correctly" do |context|
  klass = context.send(:_serializer_class_for, @person)
  assert_equal PersonSerializer, klass

  klass = context.send(:_serializer_class_for, [@person])
  assert_equal PersonSerializer, klass

  klass = context.send(:_serializer_class_for, [])
  assert_equal Granola::Rack::NilClassSerializer, klass
end

test "adds the JSON body to the response" do |context|
  context.json(@person)
  assert_equal [%q({"name":"John Doe","age":25})], context.res.body
end

test "sets the Content-Type and Content-Length on the response" do |context|
  context.json(@person)
  assert_equal "application/json", context.res.headers["Content-Type"]
  assert_equal "28", context.res.headers["Content-Length"]
end

test "sets the Last-Modified and ETag headers" do |context|
  context.json(@person)

  expected_etag = Digest::MD5.hexdigest("John Doe|987654321")
  assert_equal expected_etag, context.res.headers["ETag"]

  expected_last_modified = Time.at(987654321).httpdate
  assert_equal expected_last_modified, context.res.headers["Last-Modified"]
end

setup do
  if_modified_since = @person.updated_at + 1
  Context.new("HTTP_IF_MODIFIED_SINCE" => if_modified_since.httpdate)
end

test "doesn't set a body for a fresh response" do |context|
  context.json(@person)
  assert_equal [], context.res.body
end

test "sets the status to 304 for a fresh response" do |context|
  context.json(@person)
  assert_equal 304, context.res.status
end

test "doesn't set Content-* for a fresh response" do |context|
  context.json(@person)
  assert context.res.headers["Content-Type"].nil?
  assert context.res.headers["Content-Length"].nil?
end
