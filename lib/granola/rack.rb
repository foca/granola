require "digest/md5"
require "time"
require "granola"
require "granola/helper"
require "granola/caching"

# Mixin to render JSON in the context of a Rack application. See the #json
# method for the specifics.
module Granola::Rack
  def self.included(base)
    base.send(:include, Granola::Helper)
  end

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
  #   with:           A specific serializer class to use. If this is `nil`,
  #                   `Helper.serializer_class_for` will be used to infer the
  #                   serializer class.
  #   status:         The HTTP status to return on stale responses. Defaults to
  #                   `200`.
  #   headers:        A Hash of default HTTP headers. Defaults to an empty Hash.
  #   **json_options: Any other keywords passed will be forwarded to the
  #                   serializer's `#to_json` call.
  #
  # Raises NameError if no specific serializer is provided and we fail to infer
  #   one for this object.
  # Returns a Rack response tuple.
  def granola(object, with: nil, status: 200, headers: {}, **json_options)
    serializer = serializer_for(object, with: with)

    if serializer.last_modified
      headers["Last-Modified".freeze] = serializer.last_modified.httpdate
    end

    if serializer.cache_key
      headers["ETag".freeze] = Digest::MD5.hexdigest(serializer.cache_key)
    end

    headers["Content-Type".freeze] = serializer.mime_type

    body = Enumerator.new { |y| y << serializer.to_json(json_options) }

    [status, headers, body]
  end
end
