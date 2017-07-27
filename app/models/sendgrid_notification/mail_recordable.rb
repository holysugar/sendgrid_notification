# prepend me
module SendgridNotification
  module MailRecordable
    def sendmail(to, notification_mail, params = {})
      result = super

      m = MailHistory.create(
        key: notification_mail.key,
        to: to,
        sent_at: Time.now,
      )
      Rails.logger.error m.errors.full_messages if m.invalid? # and ignore

      result
    end
  end
end
