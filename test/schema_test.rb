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
