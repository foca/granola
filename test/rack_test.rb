require "granola/rack"
require "rack/response"

class Context
  include Granola::Rack

  attr_reader :env

  def initialize(env = {})
    @env = env
  end
end

prepare do
  @person = Person.new("John Doe", 25, Time.at(987654321))
end

setup { Context.new }

test "sets the status to 200 for a stale response" do |context|
  response = context.json(@person)
  assert_equal 200, response[0]
end

test "sets the status to a user-defined value for a stale response" do |context|
  response = context.json(@person, status: 400)
  assert_equal 400, response[0]
end

test "adds the JSON body to the response" do |context|
  response = context.json(@person)
  assert_equal [%q({"name":"John Doe","age":25})], response[2].body
end

test "adds the JSON body of an empty list to the response" do |context|
  response = context.json([])
  assert_equal ["[]"], response[2].body
end

test "sets the Content-Type and Content-Length on the response" do |context|
  response = context.json(@person)
  assert_equal "application/json", response[1]["Content-Type"]
  assert_equal "28", response[1]["Content-Length"]
end

test "sets the Last-Modified and ETag headers" do |context|
  response = context.json(@person)

  expected_etag = Digest::MD5.hexdigest("John Doe|987654321")
  assert_equal expected_etag, response[1]["ETag"]

  expected_last_modified = Time.at(987654321).httpdate
  assert_equal expected_last_modified, response[1]["Last-Modified"]
end

test "preserve response headers" do |context|
  res = Rack::Response.new
  res["Other-Header"] = "meow"
  response = context.json(@person, response: res)
  assert_equal response[1]["Other-Header"], "meow"
end

setup do
  if_modified_since = @person.updated_at + 1
  Context.new("HTTP_IF_MODIFIED_SINCE" => if_modified_since.httpdate)
end

test "doesn't set a body for a fresh response" do |context|
  response = context.json(@person)
  assert_equal [], response[2]
end

test "sets the status to 304 for a fresh response" do |context|
  response = context.json(@person)
  assert_equal 304, response[0]
end

test "doesn't set Content-* for a fresh response" do |context|
  response = context.json(@person)
  assert response[1]["Content-Type"].nil?
  assert response[1]["Content-Length"].nil?
end

