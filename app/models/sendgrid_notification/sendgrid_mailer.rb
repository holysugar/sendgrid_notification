module SendgridNotification
  class SendgridMailer < BaseMailer
    prepend MailRecordable
    class Error < StandardError; end

    def sendmail(to, notification_mail, params, attachments = [])
      body = notification_mail.apply(params)
      _sendmail(to, notification_mail, body, attachments: attachments)
    end

    def last_result
      # SendGrid::Response class
      # https://github.com/sendgrid/ruby-http-client/blob/master/lib/ruby_http_client.rb
      sendgrid_client.last_response
    end

    def last_result_success?
      sendgrid_client.last_response.try!(:success?)
    end

    private

    def sendgrid_client
      @sendgrid_client ||= SendgridClient.new
    end

    def _sendmail(to, notification_mail, body, attachments: )
      sendgrid_client.mail_send(
        from: from,
        from_name: from_name,
        to: to,
        subject: notification_mail.subject,
        body: body,
        attachments: attachments,
      )
    end
  end
end
