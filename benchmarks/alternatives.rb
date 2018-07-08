require "benchmark/ips"
require "granola"
require "jbuilder"
require "active_model_serializers"
require "fast_jsonapi"

require "oj"
require "oj_mimic_json"

Message = Struct.new(
  :content,
  :visitors,
  :author,
  :comments,
  :attachments,
  :created_at,
  :updated_at,

  # Needed for FastJsonapi
  :author_id,
  :comment_ids,
  :attachment_ids,
)
Person = Struct.new(:name, :email_address, :url)
Comment = Struct.new(:content, :created_at)
Attachment = Struct.new(:filename, :url)

# Needed for ActiveModelSerializers and FastJsonapi
[Message, Person, Comment, Attachment].each do |model|
  model.send(:include, ActiveModel::Serialization)
  model.send(:define_method, :id) { 1 }
end

SERIALIZABLE = Message.new(
  "<p>This is <i>serious</i> monkey business</p>",
  15,
  Person.new(
    "David H.",
    "'David Heinemeier Hansson' <david@heinemeierhansson.com>",
    "http://example.com/users/1-david.json"
  ),
  [
    Comment.new("Hello everyone!", Time.parse("2011-10-29T20:45:28-05:00")),
    Comment.new("To you my good sir!", Time.parse("2011-10-29T20:47:28-05:00")),
  ],
  [
    Attachment.new("forecast.xls", "http://example.com/downloads/forecast.xls"),
    Attachment.new("presentation.pdf", "http://example.com/downloads/presentation.pdf"),
  ],
  Time.parse("2011-10-29T20:45:28-05:00"),
  Time.parse("2011-10-29T20:45:28-05:00"),

  # Attributes required by FastJsonapi
  1,
  [2, 3],
  [5, 6],
)

class WithGranola
  class AuthorSerializer < Granola::Serializer
    def data
      {
        name: object.name,
        email_address: object.email_address,
        url: object.url,
      }
    end
  end

  class CommentSerializer < Granola::Serializer
    def data
      {
        content: object.content,
        created_at: object.created_at.iso8601
      }
    end
  end

  class AttachmentSerializer < Granola::Serializer
    def data
      {
        filename: object.filename,
        url: object.url,
      }
    end
  end

  class MessageSerializer < Granola::Serializer
    def data
      {
        content: object.content,
        created_at: object.created_at.iso8601,
        updated_at: object.updated_at.iso8601,
        author: AuthorSerializer.new(object.author).data,
        visitors: object.visitors,
        comments: CommentSerializer.list(object.comments).data,
        attachments: AttachmentSerializer.list(object.attachments).data,
      }
    end
  end
end

module WithActiveModel
  class AuthorSerializer < ActiveModel::Serializer
    attributes :name, :email_address, :url
  end

  class CommentSerializer < ActiveModel::Serializer
    attributes :content, :created_at

    def created_at
      object.created_at.iso8601
    end
  end

  class AttachmentSerializer < ActiveModel::Serializer
    attributes :filename, :url
  end

  class MessageSerializer < ActiveModel::Serializer
    attributes :content, :created_at, :updated_at, :visitors
    has_one :author, serializer: AuthorSerializer
    has_many :comments, serializer: CommentSerializer
    has_many :attachments, serializer: AttachmentSerializer

    def created_at
      object.created_at.iso8601
    end

    def updated_at
      object.updated_at.iso8601
    end
  end
end

module WithFastJsonApi
  class AuthorSerializer
    include FastJsonapi::ObjectSerializer
    attributes :name, :email_address, :url
  end

  class CommentSerializer
    include FastJsonapi::ObjectSerializer
    attributes :content, :created_at

    def created_at
      object.created_at.iso8601
    end
  end

  class AttachmentSerializer
    include FastJsonapi::ObjectSerializer
    attributes :filename, :url
  end

  class MessageSerializer
    include FastJsonapi::ObjectSerializer
    attributes :content, :created_at, :updated_at, :visitors
    has_one :author, serializer: AuthorSerializer
    has_many :comments, serializer: CommentSerializer
    has_many :attachments, serializer: AttachmentSerializer

    def created_at
      object.created_at.iso8601
    end

    def updated_at
      object.updated_at.iso8601
    end
  end
end

def granola(message)
  WithGranola::MessageSerializer.new(message).to_json
end

def active_model(message)
  WithActiveModel::MessageSerializer.new(message).to_json
end

def fast_jsonapi(message)
  WithFastJsonApi::MessageSerializer.new(message).serialized_json
end

def jbuilder(message)
  Jbuilder.encode do |json|
    json.content message.content
    json.(message, :created_at, :updated_at)

    json.author do
      json.name message.author.name
      json.email_address message.author.email_address
      json.url message.author.url
    end

    json.visitors message.visitors

    json.comments message.comments, :content, :created_at

    json.attachments message.attachments do |attachment|
      json.filename attachment.filename
      json.url attachment.url
    end
  end
end

Benchmark.ips do |b|
  b.report("jbuilder") { jbuilder(SERIALIZABLE) }
  b.report("active_model") { active_model(SERIALIZABLE) }
  b.report("fast_jsonapi") { fast_jsonapi(SERIALIZABLE) }
  b.report("granola") { granola(SERIALIZABLE) }
  b.compare!
end
