require "yaml"

class BaseSerializer < Granola::Serializer
  MIME_TYPES[:yaml] = "application/x-yaml".freeze

  def to_yaml(**opts)
    YAML.dump(serialized)
  end
end

User = Struct.new(:name, :age)

class UserSerializer < BaseSerializer
  def serialized
    { "name" => object.name, "age" => object.age }
  end
end

class Context
  include Granola::Rack
end

prepare do
  @user = User.new("John Doe", 25)
end

setup { Context.new }

test "allows rendering as a different format" do |context|
  status, headers, body = context.granola(@user, as: :yaml)

  assert_equal 200, status
  assert_equal "application/x-yaml", headers["Content-Type"]

  assert_equal(
    { "name" => "John Doe", "age" => 25 },
    YAML.load(body.to_a.first)
  )
end
