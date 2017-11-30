module SendgridNotification
  class NullMailer < BaseMailer
    prepend MailRecordable
    Result = Struct.new(:from, :to, :subject, :body, :sent_at)

    @@results = []
    cattr_reader :results

    def sendmail(to, notification_mail, params = {})
      body = notification_mail.apply(params)
      results << Result.new(from, to, notification_mail.subject, body, Time.now)
    end

    def last_result
      results.last
    end

    def last_result_success?
      results.present?
    end
  end
end
