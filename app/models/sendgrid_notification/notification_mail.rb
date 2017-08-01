module SendgridNotification
  class NotificationMail < ActiveRecord::Base

    with_options presence: true do
      validates :key, uniqueness: true
      validates :subject
      validates :content
    end

    class_attribute :variable_regexp

    VARIABLE_REGEXP_DEFAULT = /\{\{\s*(\w+)\s*\}\}/
    self.variable_regexp = VARIABLE_REGEXP_DEFAULT


    def sendmail_later(to, params = {})
      SendmailJob.perform_later(to, self, params)
    end

    alias_method :sendmail, :sendmail_later

    def sendmail_now(to, params = {})
      SendmailJob.perform_now(to, self, params)
    end

    def apply(params)
      unresolved = []
      body = content.gsub(variable_regexp) { |_|
        key = $1
        params[key] || params[key.to_sym] || unresolved.push(key)
      }
      if unresolved.present?
        errors.add(:content, :unresolved_template_parameters, variables: unresolved.join(","))
      end
      body
    end

  end
end
