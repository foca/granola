require "granola/schema"

class PersonSerializer < Granola::Serializer
  def self.schema
    {
      "required" => ["name"],
      "properties" => {
        "name" => { "type" => "string" },
        "age" => { "type" => "integer" }
      }
    }
  end
end

test "validates a person with valid age" do
  person = Person.new("John Doe", 29)
  serializer = PersonSerializer.new(person)
  assert serializer.valid?
end

test "validates a person with an invalid (non-integer) age" do
  person = Person.new("John Doe", "old")
  serializer = PersonSerializer.new(person)
  assert !serializer.valid?
  assert serializer.validation_errors.any?
end

test "can serialize the schema itself" do
  serializer = Granola::SchemaSerializer.new(PersonSerializer.schema)

  assert_equal \
    "http://json-schema.org/schema#",
    serializer.attributes["$schema"]

  assert_equal "object", serializer.attributes["type"]
  assert_equal ["name"], serializer.attributes["required"]
  assert_equal(
    { "type" => "integer" },
    serializer.attributes["properties"]["age"]
  )
end
