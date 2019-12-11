module SendgridNotification
  class SendmailJob < ApplicationJob
    class HTTPException < StandardError; end

    queue_as :sendmail

    MailerClass = Rails.application.config.sendgrid_notification.mailer.constantize

    def perform(to, notification_mail, params, hash_attachments = [])

      mailer = MailerClass.new(params)
      obj_attachments = hash_attachments.map{|hash| SendgridNotification::Attachment.wrap(hash.symbolize_keys) }
      mailer.sendmail(to, notification_mail, params, obj_attachments)
      raise HTTPException, mailer.last_result.body unless mailer.last_result_success?

      mailer.last_result.body
    end
  end
end
