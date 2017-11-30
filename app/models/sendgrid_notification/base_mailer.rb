module SendgridNotification
  class BaseMailer
    attr_reader :from, :from_name

    def initialize(params = {})
      _params = params.with_indifferent_access
      @from      = _params.fetch(:mail_from) { Rails.application.config.sendgrid_notification.mail_from }
      @from_name = _params.fetch(:mail_from_name) { Rails.application.config.sendgrid_notification.mail_from_name }
    end

    def sendmail(to, notification_mail, params = {})
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
