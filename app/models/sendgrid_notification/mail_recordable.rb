# prepend me
module SendgridNotification
  module MailRecordable
    def sendmail(to, notification_mail, parmas, attachments = [])
      result = super

      m = MailHistory.new(
        key: notification_mail.key,
        to: to,
        sent_at: Time.now,
      )
      m.attachment_summary = attachment_summary(attachments) if m.respond_to?(:attachment_summary=)
      m.save
      Rails.logger.error m.errors.full_messages if m.invalid? # and ignore

      result
    end

    private

    def attachment_summary(attachments)
      attachments.map do |a|
        {
          content_id: a.content_id,
          mime_type: a.mime_type,
          filename: a.filename,
          size: a.content.bytesize,
        }
      end.to_json
    end
  end
end
