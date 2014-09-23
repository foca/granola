scope do
  setup do
    Person.new("John Doe", 30, Time.at(1234567890))
  end

  test "gets the last modified date if set" do |person|
    serializer = PersonSerializer.new(person)
    assert_equal Time.at(1234567890), serializer.last_modified
  end

  test "gets the caching key" do |person|
    serializer = PersonSerializer.new(person)
    assert_equal "John Doe|1234567890", serializer.cache_key
  end
end
