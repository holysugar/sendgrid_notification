module SendgridNotification
  class NullMailer < BaseMailer
    prepend MailRecordable
    Result = Struct.new(:from, :to, :subject, :body, :sent_at, :attachments)

    @@results = []
    cattr_reader :results

    def sendmail(to, notification_mail, params, attachments = [])
      body = notification_mail.apply(params)
      results << Result.new(from, to, notification_mail.subject, body, Time.now, attachments)
    end

    def last_result
      results.last
    end

    def last_result_success?
      results.present?
    end
  end
end
