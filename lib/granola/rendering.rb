# frozen_string_literal: true
require "json"

module Granola
  class NoSuchRendererError < ArgumentError; end

  # Public: Register a new Renderer. A Renderer must be a callable that, given
  # the output of a Serializer's `data` method, will turn that into a stream
  # of the expected type.
  #
  # Registering a Renderer via this method will add a `to_#{type}` instance
  # method to the serializers, as syntax sugar for calling `Renderer#render`.
  #
  # type          - A name to identify this rendering mechanism. For example,
  #                 `:json`.
  # via:          - A callable that performs the actual rendering. See
  #                 Renderer#initialize for a description of the interface
  #                 expected of this callable.
  # content_type: - String with the expected content type when rendering
  #                 serializers in a web context. For example,
  #                 `"application/json"`
  #
  # Example:
  #
  #   Granola::Serializer.render(:json, {
  #     via: Oj.method(:dump),
  #     content_type: "application/json"
  #   })
  #
  #   Granola::Serializer.render(:msgpack, {
  #     via: MessagePack.method(:pack),
  #     content_type: "application/x-msgpack"
  #   })
  #
  # Returns nothing.
  def self.render(type, via:, content_type:)
    RENDERERS[type.to_sym] = Renderer.new(via, content_type)
    Serializer.send :define_method, "to_#{type}" do |**opts, &block|
      Granola.renderer(type).render(self, **opts, &block)
    end
  end

  # Public: Get a registered Renderer.
  #
  # type - A Symbol with the name under which a Renderer was registered. See
  #        `Granola.render`.
  #
  # Raises Granola::NoSuchRendererError if an unknown `type` is passed.
  # Returns a Granola::Renderer instance.
  def self.renderer(type)
    RENDERERS.fetch(type.to_sym) do
      fail NoSuchRendererError, "No renderer registered for #{type.inspect}"
    end
  end

  # Public: Returns an Array of types with a registered Renderer as Symbols. See
  # `Granola.render` to register a new Renderer instance.
  def self.renderable_formats
    RENDERERS.keys
  end

  # Internal: Map of renderers available to all serializers.
  RENDERERS = {}

  # Renderer objects just wrap the callable used to render an object and keep a
  # reference to the Content-Type that should be used when rendering objects
  # through it.
  #
  # You shouldn't initialize this objects. Instead, use `Granola.render` to
  # register rendering formats.
  #
  # Example:
  #
  #   Granola.render(:json, via: JSON.method(:generate),
  #                         content_type: "application/json")
  #
  #   renderer = Granola.renderer(:json)
  #   renderer.content_type #=> "application/json"
  #   renderer.render(PersonSerializer.new(person)) #=> "{...}"
  class Renderer
    # Public: Get a String with the Renderer's expected content type.
    attr_reader :content_type

    # Internal: Initialize a renderer. You should't use this method. Instead,
    # see `Granola.render` for registering a new rendering format.
    #
    # backend      - A callable that takes an object (the result of calling a
    #                Serializer's `data` method) and returns a String of data
    #                appropriately encoded for this rendering format.
    # content_type - A String with the expected content type to be returned when
    #                serializing objects through this renderer.
    def initialize(backend, content_type)
      @backend = backend
      @content_type = content_type
    end

    # Public: Render a Serializer in this format.
    #
    # serializer - An instance of Granola::Serializer.
    # options    - Any options that can be passed to the rendering backend.
    #
    # Returns a String.
    def render(serializer, **options, &block)
      @backend.call(serializer.data, **options, &block)
    end
  end

  render :json, via: JSON.method(:generate), content_type: "application/json"
end
