module SendgridNotification
  class NullMailerTest < ActiveSupport::TestCase
    setup do
      @mailer = NullMailer.new(
        mail_from: "noreply@example.com",
        mail_from_name: "Tester"
      )
      @mail = create(:notification_mail,
        key: 'sendgrid_mailer_test',
        subject: 'Sendgrid mailer テスト',
        content: '{{ emoji }}',)

      @attachment = SendgridNotification::Attachment.new(
        content_id: "example1",
        filename: "example1.png",
        content: File.read("test/fixtures/example1.png"),
        mime_type: "image/png"
      )
    end

    test 'can send mail (but fake) and store result' do
      @mailer.sendmail('sample@example.com', @mail, {emoji: "\u{1F363}"})
      assert { @mailer.from == "noreply@example.com" }
      assert { @mailer.from_name == "Tester" }
      assert { @mailer.last_result_success? }
      assert { @mailer.last_result.subject == 'Sendgrid mailer テスト' }
      assert { @mailer.last_result.body == '🍣' }
      assert { @mailer.last_result.sent_at.is_a? Time }
    end

    test '#sendmail stores mail history' do
      prev_count = MailHistory.count
      @mailer.sendmail('sample@example.com', @mail, {emoji: "\u{1F363}"}, [@attachment])
      assert { MailHistory.count    == prev_count + 1 }
      assert { MailHistory.last.to  == 'sample@example.com' }
      assert { MailHistory.last.key == 'sendgrid_mailer_test' }
      assert { MailHistory.last.attachment_summary == %|[{"content_id":"example1","mime_type":"image/png","filename":"example1.png","size":277}]| }
      assert { MailHistory.last.sent_at.is_a? Time }
    end
  end
end
