# Benchmarks

The files in this directory provide different benchmarks to ensure that Granola
is performant, or to test its performance under different scenarios.

The output is from running them on a development machine, so it should be
considered relative, and I encourage you to run them in different platforms.

## How to run

Install dependencies for the benchmarks by running [`dep install`][dep] from the 
benchmarks directory.

Run each file normally. For example: `ruby ./alternatives.rb`

[dep]: https://github.com/djanowski/dep

## MultiJson

[MultiJson][] provides a way of unifying multiple libraries and systems to use
the same JSON rendering backend by configuring it in one place. However, this
comes at a cost.

At the time of writing:

```
Warming up --------------------------------------
               plain    39.265k i/100ms
          multi_json     4.064k i/100ms
Calculating -------------------------------------
               plain    495.215k (± 3.4%) i/s -      2.474M in   5.001015s
          multi_json     41.297k (± 9.0%) i/s -    207.264k in   5.066882s

Comparison:
               plain:   495214.7 i/s
          multi_json:    41297.2 i/s - 11.99x  slower
```

[MultiJson]: https://github.com/intridea/multi_json

## Alternatives

Granola is not the only way of managing the logic around generating specific
responses for an API. Commonly used in ruby are [ActiveModel::Serializers][AMS],
[Jbuilder][], and more recently [Fast JSON API][fjapi].

`ActiveModel::Serializers` offers a ton of features, which are great if you need
them, but as you can see from this benchmark, are also pretty encumbering when
you don't.

`Jbuilder`, a tool maintained by the [Rails][] team, takes a completely
different approach to the problem, by considering that JSON rendering is a
responsibility of the template layer, and using templates to generate JSON
responses.

`Fast JSON API` is a tool maintained by [Netflix][], which was built to be
similar to `ActiveModel::Serializers`, but fast. As you can see from the below
benchmarks, it's comparable to Granola in performance. I personally am not a fan
of adding mroe cognitive load with complex DSLs that you have to learn and
understand, so I still prefer Granola's simplicity. But I'm obviously biased :)

At the time of writing:

```
Warming up --------------------------------------
            jbuilder     1.397k i/100ms
        active_model   497.000  i/100ms
        fast_jsonapi     3.122k i/100ms
             granola     3.083k i/100ms
Calculating -------------------------------------
            jbuilder     13.690k (± 3.7%) i/s -     68.453k in   5.007391s
        active_model      4.378k (±15.1%) i/s -     21.371k in   5.044318s
        fast_jsonapi     26.016k (±13.9%) i/s -    128.002k in   5.028594s
             granola     27.124k (±14.1%) i/s -    132.569k in   5.000011s

Comparison:
             granola:    27123.9 i/s
        fast_jsonapi:    26016.0 i/s - same-ish: difference falls within error
            jbuilder:    13689.9 i/s - 1.98x  slower
        active_model:     4377.9 i/s - 6.20x  slower
```

[AMS]: https://github.com/rails-api/active_model_serializers
[Jbuilder]: https://github.com/rails/jbuilder
[Rails]: https://github.com/rails/rails
[fjapi]: https://github.com/netflix/fast_jsonapi
[Netflix]: https://netflix.github.io
