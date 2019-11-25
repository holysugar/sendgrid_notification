require 'sendgrid-ruby'

module SendgridNotification
  class Attachment
    include ActiveModel::Model
    include ActiveModel::Attributes # Rails 5.2

    validates :content_id, :filename, :content, presence: true

    attribute :content_id, :string
    attribute :filename, :string
    attribute :content, :string
    attribute :mime_type, :string, default: "application/octet-stream"
    attribute :disposition, :string, default: "attachment"

    alias_method :to_h, :attributes

    def as_sendgrid
      a = ::SendGrid::Attachment.new
      a.content_id = content_id
      a.filename = filename
      a.content = Base64.strict_encode64(content)
      a.type = mime_type
      a.disposition = disposition
      a
    end

    def self.wrap(hash_or_attachment)
      case hash_or_attachment
      when Attachment
        self
      else
        Attachment.new(**hash_or_attachment.to_h)
      end
    end
  end
end
