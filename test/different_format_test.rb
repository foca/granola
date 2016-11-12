require "yaml"

Granola.render(:yaml, {
  via: YAML.method(:dump),
  content_type: "application/x-yaml",
})

User = Struct.new(:name, :age)

class UserSerializer < Granola::Serializer
  def data
    { "name" => object.name, "age" => object.age }
  end
end

setup do
  UserSerializer.new(User.new("John Doe", 25))
end

test "allows rendering as a different format" do |serializer|
  body = serializer.render(:yaml)
  assert_equal({ "name" => "John Doe", "age" => 25 }, YAML.load(body))
end
