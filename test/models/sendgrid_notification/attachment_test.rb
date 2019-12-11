require "test_helper"

module SendgridNotification
  class AttachmentTest < ActiveSupport::TestCase
    test "SendgridAttachment" do
      attachment = SendgridNotification::Attachment.new(
        content_id: "example1",
        filename: "example1.png",
        content: File.read("test/fixtures/example1.png"),
        mime_type: "image/png"
      )

      assert { attachment.is_a? SendgridNotification::Attachment }
      assert { attachment.as_sendgrid.is_a? SendGrid::Attachment }
      assert { attachment.as_sendgrid.content !~ /\s/ }
      assert { Base64.strict_decode64 attachment.as_sendgrid.content } # not raised
    end
  end
end
