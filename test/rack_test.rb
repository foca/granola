require "granola/rack"

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
  status, headers, body = context.granola(@person)
  assert_equal 200, status
end

test "sets the status to a user-defined value for a stale response" do |context|
  status, headers, body = context.granola(@person, status: 400)
  assert_equal 400, status
end

test "adds the JSON body to the response" do |context|
  status, headers, body = context.granola(@person)
  assert_equal [%q({"name":"John Doe","age":25})], body.to_a
end

test "adds the JSON body of an empty list to the response" do |context|
  status, headers, body = context.granola([])
  assert_equal ["[]"], body.to_a
end

test "sets the Content-Type on the response" do |context|
  status, headers, body = context.granola(@person)
  assert_equal "application/json", headers["Content-Type"]
end

test "sets the Last-Modified and ETag headers" do |context|
  status, headers, body = context.granola(@person)

  expected_etag = Digest::MD5.hexdigest("John Doe|987654321")
  assert_equal expected_etag, headers["ETag"]

  expected_last_modified = Time.at(987654321).httpdate
  assert_equal expected_last_modified, headers["Last-Modified"]
end

test "allows passing default headers" do |context|
  default_headers = { "Other-Header" => "Meow" }
  status, headers, body = context.granola(@person, headers: default_headers)

  assert_equal "application/json", headers["Content-Type"]
  assert_equal "Meow", headers["Other-Header"]
end
