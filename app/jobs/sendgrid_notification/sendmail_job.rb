module SendgridNotification
  class SendmailJob < ActiveJob::Base
    queue_as :sendmail

    MailerClass = Rails.application.config.sendgrid_notification.mailer.constantize

    def perform(to, notification_mail, params)
      MailerClass.new.sendmail(to, notification_mail, params)
    end
  end
end
