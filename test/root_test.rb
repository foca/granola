class BaseSerializer < Granola::Serializer
  def to_serializer
    RootSerializer.new(self)
  end
end

class RootSerializer < Granola::Serializer
  def data
    { "results" => object.data }.update(meta)
  end
  
  def meta
    object.respond_to?(:meta) ? { "meta" => object.meta } : {}
  end
end

class UserSerializer < BaseSerializer
  def data
    {
      id: object.id,
      email: object.email,
      projects: ProjectSerializer.list(object.projects).data,
    }
  end

  def meta
    {
      "_self" => "https://example.com/api/users/#{object.id}",
    }
  end
end

class ProjectSerializer < BaseSerializer
  def data
    {
      id: object.id,
      name: object.name,
    }
  end

  def meta
    {
      "_self" => "https://example.com/api/projects/#{object.id}",
    }
  end
end

User = Struct.new(:id, :email, :projects)
Project = Struct.new(:id, :name)

scope do
  setup do
    User.new(1, "jane@example.com", [
      Project.new(1, "First Project"),
      Project.new(2, "Second Project"),
    ])
  end

  test "wraps object to include root keys" do |object|
    serializer = UserSerializer.new(object)

    expected = {
      "results" => {
        "id" => 1,
        "email" => "jane@example.com",
        "projects" => [
          { "id" => 1, "name" => "First Project" },
          { "id" => 2, "name" => "Second Project" },
        ],
      },
      "meta" => {
        "_self" => "https://example.com/api/users/1",
      },
    }

    assert_equal JSON.dump(expected), serializer.to_json
  end
end
