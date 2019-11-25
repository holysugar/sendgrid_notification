module SendgridNotification
  class BaseMailer
    attr_reader :from, :from_name

    def initialize(params = {})
      _params = params.with_indifferent_access
      @from      = _params.fetch(:mail_from) { Rails.application.config.sendgrid_notification.mail_from }
      @from_name = _params.fetch(:mail_from_name) { Rails.application.config.sendgrid_notification.mail_from_name }
    end

    # Send mail about:
    # +to+ recipent to
    # +notification_mail+ NotificationMail object for mail expression
    # +params+ params for notification_mail
    # +attachments+ attachment in hash or SendgridNotification::Attachment
    def sendmail(to, notification_mail, params, attachments = [])
      raise NotImplementedError, "you should implement #{self.class}##{__method__}"
    end

    def last_result
      raise NotImplementedError, "you should implement #{self.class}##{__method__}"
    end

    def last_result_success?
      raise NotImplementedError, "you should implement #{self.class}##{__method__}"
    end
  end
end
