require "benchmark"
require "granola"
require "active_support/core_ext/module/delegation"
require "active_model_serializers"

require "oj"
require "oj_mimic_json"

Director = Struct.new(:name) do
  include ActiveModel::Serialization
end

Movie = Struct.new(:title, :year, :director) do
  include ActiveModel::Serialization
end

SERIALIZABLE = [
  Movie.new("The Shawshank Redemption", 1994, Director.new("Frank Darabont")),
  Movie.new("The Usual Suspects", 1995, Director.new("Bryan Singer")),
  Movie.new("The Matrix", 1999, Director.new("The Wachowskis")),
]

module WithGranola
  class MovieSerializer < Granola::Serializer
    def data
      {
        title: object.title,
        year: object.year,
        director: WithGranola::DirectorSerializer.new(object.director).data
      }
    end
  end

  class DirectorSerializer < Granola::Serializer
    def data
      {
        name: object.name
      }
    end
  end
end

module WithActiveModel
  class DirectorSerializer < ActiveModel::Serializer
    attributes :name
  end

  class MovieSerializer < ActiveModel::Serializer
    attributes :title, :year
    has_one :director, serializer: ::WithActiveModel::DirectorSerializer
  end
end

def granola
  WithGranola::MovieSerializer.list(SERIALIZABLE).to_json
end

def active_model
  ActiveModel::Serializer::CollectionSerializer.new(
    SERIALIZABLE, serializer: WithActiveModel::MovieSerializer
  ).to_json
end

Benchmark.bmbm do |b|
  b.report("active_model") { 10_000.times { active_model } }
  b.report("granola") { 10_000.times { granola } }
end
