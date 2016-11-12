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
responses for an API. Commonly used in ruby are [ActiveModel::Serializers][AMS]
and [Jbuilder][].

`ActiveModel::Serializers` offers a ton of features, which are great if you need
them, but as you can see from this benchmark, are also pretty encumbering when
you don't.

`Jbuilder`, a tool maintained by the [Rails][] team, takes a completely
different approach to the problem, by considering that JSON rendering is a
responsibility of the template layer, and using templates to generate JSON
responses.

At the time of writing:

```
Warming up --------------------------------------
            jbuilder     1.128k i/100ms
        active_model   457.000  i/100ms
             granola     2.514k i/100ms
Calculating -------------------------------------
            jbuilder     13.831k (± 4.6%) i/s -     69.936k in   5.068908s
        active_model      4.685k (± 3.7%) i/s -     23.764k in   5.079607s
             granola     24.930k (± 6.7%) i/s -    125.700k in   5.068210s

Comparison:
             granola:    24929.6 i/s
            jbuilder:    13831.0 i/s - 1.80x  slower
        active_model:     4685.3 i/s - 5.32x  slower
```

[AMS]: https://github.com/rails-api/active_model_serializers
[Jbuilder]: https://github.com/rails/jbuilder
[Rails]: https://github.com/rails/rails
