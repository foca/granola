# Granola, a JSON serializer [![Build Status](https://img.shields.io/travis/foca/granola.svg)](https://travis-ci.org/foca/granola) [![RubyGem](https://img.shields.io/gem/v/granola.svg)](https://rubygems.org/gems/granola)

![A tasty bowl of Granola](https://cloud.githubusercontent.com/assets/437/4827156/9e8d33da-5f76-11e4-8574-7803e84845f2.JPG)

Granola aims to provide a simple interface to generate JSON responses based on
your application's domain models. It doesn't make assumptions about anything and
gets out of your way. You just write plain ruby.

## Example

``` ruby
class PersonSerializer < Granola::Serializer
  def serialized
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
to change it. For example, if you were using [Yajl][]:

``` ruby
Granola.json = Yajl::Encoder.method(:encode)
```

If your project already uses [MultiJson][] then we will default to whatever it's
using, so you shouldn't worry.

[Yajl]: https://github.com/brianmario/yajl-ruby
[MultiJson]: https://github.com/intridea/multi_json

## Handling lists of models

A Granola serializer can handle a list of entities of the same type by using the
`Serializer.list` method (instead of `Serializer.new`). For example:

``` ruby
serializer = PersonSerializer.list(Person.all)
serializer.to_json #=> '[{"name":"John Doe",...},{...}]'
```

## Rack Helpers

If your application is based on Rack, you can simply `include Granola::Rack` and
you get access to the following interface:

``` ruby
granola(person) #=> This will infer PersonSerializer from a Person instance
granola(person, with: AnotherSerializer)
```

*NOTE* The method relies on being an `env` method that returns the Rack
environment Hash in the same context where you call the method. See [the
documentation](./lib/granola/rack.rb) for further details.

This method returns a Rack response tuple that you can use like so (this example
uses [Cuba][], but similar code will work for other frameworks):

``` ruby
Cuba.plugin Granola::Rack

Cuba.define do
  on get, "users/:id" do |id|
    user = User[id]
    halt granola(user)
  end
end
```

[Cuba]: http://cuba.is

## Caching

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
  def serialized
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

## Different Formats

Although Granola out of the box only ships with JSON serialization support, it's
easy to extend and add support for different types of serialization in case your
API needs to provide multiple formats. For example, in order to add MsgPack
support (via the [msgpack-ruby][] library), you'd do this:

``` ruby
require "msgpack"

class BaseSerializer < Granola::Serializer
  MIME_TYPES[:msgpack] = "application/x-msgpack".freeze

  def to_msgpack(*)
    MsgPack.pack(serialized)
  end
end
```

Now all serializers that inherit from `BaseSerializer` can be serialized into
MsgPack. In order to use this from our Rack helpers, you'd do:

``` ruby
granola(object, as: :msgpack)
```

This will set the correct MIME type.

[msgpack-ruby]: https://github.com/msgpack/msgpack-ruby

## License

This project is shared under the MIT license. See the attached LICENSE file for
details.
