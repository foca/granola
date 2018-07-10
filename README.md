# Granola, a JSON serializer [![Build Status](https://img.shields.io/travis/foca/granola.svg)](https://travis-ci.org/foca/granola) [![RubyGem](https://img.shields.io/gem/dt/granola.svg)](https://rubygems.org/gems/granola)

![A tasty bowl of Granola](https://cloud.githubusercontent.com/assets/437/4827156/9e8d33da-5f76-11e4-8574-7803e84845f2.JPG)

Granola aims to provide a simple interface to generate JSON responses based on
your application's domain models. It doesn't make assumptions about anything and
gets out of your way. You just write plain ruby.

## Example

``` ruby
class PersonSerializer < Granola::Serializer
  def data
    {
      "name" => object.name,
      "email" => object.email,
      "age" => object.age
    }
  end
end

PersonSerializer.new(person).to_json #=> '{"name":"John Doe",...}'
```

## Install

    gem install granola

## JSON serialization

Granola doesn't make assumptions about your code, so it shouldn't depend on a
specific JSON backend. It defaults to the native JSON backend, but you're free
to change it. For example, if you were using [Oj][]:

``` ruby
Granola.render :json, via: Oj.method(:dump),
                      content_type: "application/json"
```

[Oj]: https://github.com/ohler55/oj

## Handling lists of entities

A Granola serializer can handle a list of entities of the same type by using the
`Serializer.list` method (instead of `Serializer.new`). For example:

``` ruby
serializer = PersonSerializer.list(Person.all)
serializer.to_json #=> '[{"name":"John Doe",...},{...}]'
```

## Rack Helpers

If your application is based on Rack, you can `require "granola/rack"` instead
of `require "granola"`, and then simply `include Granola::Rack` to get access
to the following interface:

``` ruby
granola(person) #=> This will infer PersonSerializer from a Person instance
granola(person, with: AnotherSerializer)
```

This method returns a Rack response tuple that you can use like so (this example
uses [Cuba][], but similar code will work for other frameworks):

``` ruby
require "granola/rack"

Cuba.plugin Granola::Rack

Cuba.define do
  on get, "users/:id" do |id|
    user = User[id]
    halt granola(user)
  end
end
```

[Cuba]: http://cuba.is

## Rails Support

The companion [Granola::Rails](https://github.com/foca/granola-rails) gem takes
care of support for Rails.

## HTTP Caching

`Granola::Serializer` gives you two methods that you can implement in your
serializers: `last_modified` and `cache_key`.

When using the `Granola::Rack` module, you should return a `Time` object from
your serializer's `last_modified`.  Granola will use this to generate the
appropriate `Last-Modified` HTTP header.  Likewise, the result of `cache_key`
will be MD5d and set as the response's `ETag` header.

If you do this, you should also make sure that the [`Rack::ConditionalGet`][cg]
middleware is in your Rack stack, as it will use these headers to avoid
generating the JSON response altogether. For example, using Cuba:

``` ruby
class UserSerializer < Granola::Serializer
  def data
    { "id" => object.id, "name" => object.name, "email" => object.email }
  end

  def last_modified
    object.updated_at
  end

  def cache_key
    "user:#{object.id}:#{object.updated_at.to_i}"
  end
end

Cuba.plugin Granola::Rack
Cuba.use Rack::ConditionalGet

Cuba.define do
  on get, "users/:id" do |id|
    halt granola(User[id])
  end
end
```

This will avoid generating the JSON response altogether if the user sends the
appropriate `If-Modified-Since` or `If-None-Match` headers.

[cg]: http://www.rubydoc.info/github/rack/rack/Rack/ConditionalGet

## Caching of serialized bodies

If you are generating responses that are particularly expensive to serialize,
you can use the [Granola::Cache](https://github.com/foca/granola-cache) gem to
store their representations once generated in an external cache.

## Different Formats

Although Granola out of the box only ships with JSON serialization support, it's
easy to extend and add support for different types of serialization in case your
API needs to provide multiple formats. For example, in order to add MsgPack
support (via the [msgpack-ruby][] library), you'd do this:

``` ruby
require "msgpack"

Granola.render :msgpack, via: MessagePack.method(:pack),
                         content_type: "application/x-msgpack"
```

Now all serializers can be serialized into MsgPack using a `to_msgpack` method.
In order to use this from our Rack helpers, you'd do:

``` ruby
granola(object, as: :msgpack)
```

This will set the correct MIME type.

If you don't explicitly set a format when rendering via the rack helper, Granola
will use the request's `Accept` header to choose the best format for rendering.

For example, given a request with the following header:

    Accept: text/x-yaml;q=0.5,application/x-msgpack;q=0.8,*/*;q=0.2

Granola will check first if you have a renderer registered for the
`application/x-msgpack` MIME type, and then check for a renderer for the
`text/x-yaml` MIME type. If none of these are registered, it will default to
rendering JSON.

[msgpack-ruby]: https://github.com/msgpack/msgpack-ruby

## License

This project is shared under the MIT license. See the attached [LICENSE][] file
for details.

[LICENSE]: ./LICENSE
