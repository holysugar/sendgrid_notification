module SendgridNotification
  class NullMailerTest < ActiveSupport::TestCase
    setup do
      @mailer = NullMailer.new
      @mail = create(:notification_mail,
        key: 'sendgrid_mailer_test',
        subject: 'Sendgrid mailer テスト',
        content: '{{ emoji }}',)
    end

    test 'can send mail (but fake) and store result' do
      @mailer.sendmail('sample@exmaple.com', @mail, emoji: "\u{1F363}")
      assert { @mailer.last_result_success? }
      assert { @mailer.last_result.subject == 'Sendgrid mailer テスト' }
      assert { @mailer.last_result.body == '🍣' }
      assert { @mailer.last_result.sent_at.is_a? Time }
    end

    test '#sendmail stores mail history' do
      prev_count = MailHistory.count
      @mailer.sendmail('sample@exmaple.com', @mail, emoji: "\u{1F363}")
      assert { MailHistory.count    == prev_count + 1 }
      assert { MailHistory.last.to  == 'sample@exmaple.com' }
      assert { MailHistory.last.key == 'sendgrid_mailer_test' }
      assert { MailHistory.last.sent_at.is_a? Time }
    end
  end
end
