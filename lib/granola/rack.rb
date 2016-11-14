require "digest/md5"
require "time"
require "granola"
require "granola/caching"
require "rack/utils"

module Granola
  # Mixin to render JSON in the context of a Rack application. See the #json
  # method for the specifics.
  module Rack
    # Public: Renders a JSON representation of an object using a
    # Granola::Serializer. This takes care of setting the `Last-Modified` and
    # `ETag` headers if appropriate.
    #
    # You can customize the response tuple by passing the status and the default
    # headers, as in the following example:
    #
    #   granola(user, status: 400, headers: { "X-Error" => "Boom!" })
    #
    # object - An object to serialize into JSON.
    #
    # Keywords:
    #   with:    A specific serializer class to use. If this is `nil`,
    #            `Util.serializer_class_for` will be used to infer the
    #            serializer class.
    #   as:      A Symbol with the type of serialization desired. Defaults to
    #            `:json` (and it's the only one available by default), but could
    #            be expanded with plugins to provide serialization to, for
    #            example, MsgPack.
    #   status:  The HTTP status to return on stale responses. Defaults to `200`
    #   headers: A Hash of default HTTP headers. Defaults to an empty Hash.
    #   **opts:  Any other keywords passed will be forwarded to the serializer's
    #            serialization backend call.
    #
    # Raises NameError if no specific serializer is provided and we fail to
    # infer one for this object.
    #
    # Returns a Rack response tuple.
    def granola(object, with: nil, status: 200, headers: {}, as: nil, **opts)
      serializer = Granola::Util.serializer_for(object, with: with)

      if serializer.last_modified
        headers["Last-Modified".freeze] = serializer.last_modified.httpdate
      end

      if serializer.cache_key
        headers["ETag".freeze] = Digest::MD5.hexdigest(serializer.cache_key)
      end

      format = as || Granola::Rack.best_format_for(env["HTTP_ACCEPT"]) || :json

      headers["Content-Type".freeze] = serializer.mime_type(format)

      body = Enumerator.new do |yielder|
        yielder << serializer.render(format, opts)
      end

      [status, headers, body]
    end

    # Internal: Infer the best rendering format based on the value of an Accept
    # header and the available registered renderers.
    #
    # If there are renderers registered for JSON, and MessagePack, an Accept
    # header preferring MessagePack over JSON will result in the response being
    # serialized into MessagePack instead of JSON, unless the user explicitly
    # prefers JSON.
    #
    # accept              - String with the value of an HTTP Accept header.
    # available_renderers - Map of registered renderers. Defaults to
    #                       `Granola::RENDERERS`.
    #
    # Returns a Symbol with a Renderer type, or `nil` if none could be inferred.
    def self.best_format_for(accept, available_renderers = Granola::RENDERERS)
      formats = available_renderers.map { |f, r| [r[:content_type], f] }.to_h

      ::Rack::Utils.q_values(accept).sort_by { |_, q| -q }.each do |type, _|
        format = formats[type]
        return format unless format.nil?
      end

      nil
    end
  end
end
