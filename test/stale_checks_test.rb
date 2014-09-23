require "granola/rack"

StaleCheck = Granola::Rack::StaleCheck

modified_date = Time.at(987654321)
modified_before = Time.at(987654321 - 1)
modified_after = Time.at(987654321 + 1)

scope do # For missing information (either headers or serializer caching data)
  test "stale check is stale if last_modified and cache_key are nil" do
    env = {
      "HTTP_IF_MODIFIED_SINCE" => "Thu, 19 Apr 2001 04:25:21 GMT",
      "HTTP_IF_NONE_MATCH" => "abcdef"
    }
    check = StaleCheck.new(env, last_modified: nil, etag: nil)
    assert check.stale?
  end

  test "stale check is stale if headers aren't present" do
    check = StaleCheck.new({}, last_modified: modified_after, etag: "abcdef")
    assert check.stale?
  end
end

scope do # For requests with If-Modified-Since but no If-None-Match
  setup do
    # The time is Time.at(987654321)
    { "HTTP_IF_MODIFIED_SINCE" => "Thu, 19 Apr 2001 04:25:21 GMT" }
  end

  test "stale check is fresh for old last_modified dates" do |env|
    check = StaleCheck.new(env, last_modified: modified_before)
    assert check.fresh?
  end

  test "stale check is fresh for last_modified == If-Modified-Since" do |env|
    check = StaleCheck.new(env, last_modified: modified_date)
    assert check.fresh?
  end

  test "stale check is stale for newer last_modified dates" do |env|
    check = StaleCheck.new(env, last_modified: modified_after)
    assert check.stale?
  end
end

scope do # For requests with If-None-Match but no If-Modified-Since 
  setup do
    { "HTTP_IF_NONE_MATCH" => "abcdef, ghijkl" }
  end

  test "stale check is fresh for matching etag" do |env|
    check = StaleCheck.new(env, etag: "abcdef")
    assert check.fresh?

    check = StaleCheck.new(env, etag: "ghijkl")
    assert check.fresh?
  end

  test "stale check is fresh for If-None-Match: *" do
    env = { "HTTP_IF_NONE_MATCH" => "*" }

    check = StaleCheck.new(env, etag: "zyxwvu")
    assert check.fresh?
  end

  test "stale check is stale for non-matching etag" do |env|
    check = StaleCheck.new(env, etag: "zyxwvu")
    assert check.stale?
  end
end

scope do # For requests with both If-Modified-Since and If-None-Match
  setup do
    {
      "HTTP_IF_MODIFIED_SINCE" => "Thu, 19 Apr 2001 04:25:21 GMT",
      "HTTP_IF_NONE_MATCH" => "abcdef, ghijkl"
    }
  end

  test "is fresh if both match" do |env|
    check = StaleCheck.new(env, etag: "abcdef", last_modified: modified_before)
    assert check.fresh?
  end

  test "is fresh if only the If-None-Match matches" do |env|
    check = StaleCheck.new(env, etag: "abcdef", last_modified: modified_after)
    assert check.fresh?
  end

  test "is fresh if only the If-Modified-Since matches" do |env|
    check = StaleCheck.new(env, etag: "zyxwvu", last_modified: modified_before)
    assert check.fresh?
  end

  test "is stale if neither match" do |env|
    check = StaleCheck.new(env, etag: "zyxwvu", last_modified: modified_after)
    assert check.stale?
  end
end
