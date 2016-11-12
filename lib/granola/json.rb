require "granola/rendering"
require "json"

module Granola
  method = if defined?(MultiJson)
             MultiJson.method(:dump)
           else
             JSON.method(:generate)
           end

  render :json, via: method, content_type: "application/json"
end
