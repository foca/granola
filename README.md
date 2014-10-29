# Granola, a JSON serializer

Granola aims to provide a simple interface to generate JSON responses based on
your application's domain models. It doesn't make assumptions about anything and
gets out of your way. You just write plain ruby.

## Example

``` ruby
class PersonSerializer < Granola::Serializer
  def attributes
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
specific JSON backend. It uses [MultiJson][] to serialize your objects with your
favorite backend.

Try to avoid using the default, which is the `stdlib`'s pure-ruby JSON library,
since it's slow. If in doubt, I like [Yajl][].

If you want to pass options to `MultiJson` (like `pretty: true`), any keywords
passed to `#to_json` will be forwarded to `MultiJson.dump`.

[MultiJson]: https://github.com/intridea/multi_json
[Yajl]: https://github.com/brianmario/yajl-ruby

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
json(person) #=> This will try to infer PersonSerializer from a Person instance
json(person, with: AnotherSerializer)
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
    halt json(user)
  end
end
```

[Cuba]: http://cuba.is

## Caching

`Granola::Serializer` gives you to methods that you can implement in your
serializers, `last_modified` and `cache_key`, that will be used to prevent
rendering JSON at all if possible, when using the `Granola::Rack#json` helper.

If your serializer implements this method, and the `env` has the appropriate
`If-Modified-Since` or `If-None-Match` headers, the helper will automatically
return a 304 response.

Plus, it sets appropriate `ETag` and `Last-Modified` so your clients can avoid
hitting the endpoint altogether.

## License

This project is shared under the MIT license. See the attached LICENSE file for
details.
