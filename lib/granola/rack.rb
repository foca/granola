require "digest/md5"
require "time"
require "granola"
require "granola/helper"
require "granola/caching"

module Granola::Rack
  def self.included(base)
    base.send(:include, Granola::Helper)
  end

  def json(object, with: nil, **json_options)
    serializer = serializer_for(object, with: with)

    if serializer.last_modified
      res["Last-Modified".freeze] = serializer.last_modified.httpdate
    end

    if serializer.cache_key
      res["ETag".freeze] = Digest::MD5.hexdigest(serializer.cache_key)
    end

    stale_check = StaleCheck.new(
      env, last_modified: serializer.last_modified, etag: serializer.cache_key
    )

    if stale_check.fresh?
      res.status = 304
    else
      json_string = serializer.to_json(json_options)
      res["Content-Type".freeze] = "application/json".freeze
      res["Content-Length".freeze] = json_string.length.to_s
      res.write(json_string)
    end
  end

  def self.serializer_class_for(object)
    object = object.respond_to?(:to_ary) ? object.to_ary.fetch(0, nil) : object
    const_get("#{object.class.name}Serializer")
  end

  class NilClassSerializer < Granola::Serializer
    def attributes
      {}
    end
  end

  class StaleCheck
    attr_reader :env
    attr_reader :last_modified
    attr_reader :etag

    IF_MODIFIED_SINCE = "HTTP_IF_MODIFIED_SINCE".freeze
    IF_NONE_MATCH = "HTTP_IF_NONE_MATCH".freeze

    def initialize(env, last_modified: nil, etag: nil)
      @env = env
      @last_modified = last_modified
      @etag = etag

      @check_time = env.key?(IF_MODIFIED_SINCE) && !last_modified.nil?
      @check_etag = env.key?(IF_NONE_MATCH) && !etag.nil?
    end

    def fresh?
      (@check_time && fresh_by_time?) || (@check_etag && fresh_by_etag?)
    end

    def stale?
      !fresh?
    end

    def fresh_by_time?
      if_modified_since = Time.parse(env.fetch(IF_MODIFIED_SINCE))
      last_modified <= if_modified_since
    end

    def fresh_by_etag?
      if_none_match = env.fetch(IF_NONE_MATCH, "").split(/\s*,\s*/)
      return false if if_none_match.empty?
      return true if if_none_match.include?("*".freeze)
      if_none_match.any? { |tag| tag == etag }
    end
  end
end
