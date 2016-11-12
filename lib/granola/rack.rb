require "digest/md5"
require "time"
require "granola/serializer"
require "granola/util"
require "granola/caching"

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
    def granola(object, with: nil, status: 200, headers: {}, as: :json, **opts)
      serializer = Granola::Util.serializer_for(object, with: with)

      if serializer.last_modified
        headers["Last-Modified".freeze] = serializer.last_modified.httpdate
      end

      if serializer.cache_key
        headers["ETag".freeze] = Digest::MD5.hexdigest(serializer.cache_key)
      end

      headers["Content-Type".freeze] = serializer.mime_type(as)

      body = Enumerator.new do |yielder|
        yielder << serializer.render(as, opts)
      end

      [status, headers, body]
    end
  end
end
