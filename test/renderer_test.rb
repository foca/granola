require "yaml"

Granola.render(:yaml, {
  via: YAML.method(:dump),
  content_type: "text/x-yaml",
})

User = Struct.new(:name, :age)

class UserSerializer < Granola::Serializer
  def data
    { "name" => object.name, "age" => object.age }
  end
end

scope do
  setup do
    UserSerializer.new(User.new("John Doe", 25))
  end

  test "allows rendering as a different format" do |serializer|
    body = serializer.to_yaml
    assert_equal({ "name" => "John Doe", "age" => 25 }, YAML.load(body))
  end
end

scope do
  test "renderers know their content type" do
    renderer = Granola.renderer(:json)
    assert_equal "application/json", renderer.content_type

    renderer = Granola.renderer(:yaml)
    assert_equal "text/x-yaml", renderer.content_type
  end

  test "fails with a custom ArgumentError when an unknown renderer is sought" do
    assert_raise Granola::NoSuchRendererError do
      Granola.renderer(:nope)
    end

    assert Granola::NoSuchRendererError < ArgumentError
  end

  test "lists the formats registered for rendering" do
    assert_equal [:json, :yaml], Granola.renderable_formats
  end
end
