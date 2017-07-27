module SendgridNotification
  class MailHistory < ActiveRecord::Base
    belongs_to :notification_mail, primary_key: :key, foreign_key: :key, required: false

    with_options presence: true do
      validates :key
      validates :to
      validates :sent_at
    end

    def error?
      error_type?
    end
  end
end
