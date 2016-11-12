module Granola
  # Public: Register a new renderer. A renderer must be a callable that, given
  # the output of a Serializer's `data` method, will turn that into a stream
  # of the expected type.
  #
  # Adding a renderer via this method will add a `to_#{type}` instance method
  # to the serializers, as syntax sugar for `Serializer#render`.
  #
  # type          - A name to identify this rendering mechanism. For example,
  #                 `:json`.
  # via:          - A callable that performs the actual rendering. This
  #                 callable must take a single argument (the result of a
  #                 Serializer's `data`) and optionally a set of keyword
  #                 arguments or an options Hash.
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
    RENDERERS[type.to_sym] = { content_type: content_type, via: via }.freeze
    Serializer.send :define_method, "to_#{type}" do |**opts, &block|
      render(type, **opts, &block)
    end
  end

  # Internal: Map of renderers available to this serializer. See
  # `Granola.render`.
  RENDERERS = {}

  class Serializer
    # Public: Serialize this instance into the desired format. See
    # `Serializer.render` for how to register new rendering formats.
    #
    # type      - A Symbol with the expected rendering format.
    # **options - An options Hash or set of keyword arguments that will be
    #             passed to the renderer.
    #
    # Raises KeyError if there's no Renderer registered for the given `type`.
    # Returns a String (in the encoding approrpriate to the rendering format.)
    def render(type = :json, **options, &block)
      Granola::RENDERERS.fetch(type).fetch(:via).call(data, **options, &block)
    end

    # Internal: Returns a MIME type appropriate for the desired rendering
    # format. See `Serializer.render`.
    #
    # type - A Symbol describing the expected rendering format.
    #
    # Raises KeyError if there's no Renderer registered for the given `type`.
    # Returns a String.
    def mime_type(type = :json)
      Granola::RENDERERS.fetch(type).fetch(:content_type)
    end
  end
end
