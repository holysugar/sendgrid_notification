module SendgridNotification
  class SendgridMailerTest < ActiveSupport::TestCase
    include SendgridTestHelper

    setup do
      skip_unless_sendgrid_api_key

      @mailer = SendgridMailer.new(
        mail_from: "noreply@example.com",
        mail_from_name: "Tester"
      )
      @mailto = ENV['MAILTO']

      @mail = create(:notification_mail,
        key: 'sendgrid_mailer_test',
        subject: 'Sendgrid mailer テスト',
        content: "\u{1F363} Sendgrid mailer テスト for {{ name }}! \u{1F355}",)

      @attachment = SendgridNotification::Attachment.new(
        content_id: "example1",
        filename: "example1.png",
        content: File.read("test/fixtures/example1.png"),
        mime_type: "image/png"
      )
    end

    test 'sendmail' do
      skip unless @mailto
      prev_count = MailHistory.count

      @mailer.sendmail(@mailto, @mail, {name: ENV['USER']}, [@attachment])
      assert { @mailer.from == "noreply@example.com" }
      assert { @mailer.from_name == "Tester" }
      assert { @mailer.last_result_success? }

      assert { MailHistory.count    == prev_count + 1 }
      assert { MailHistory.last.to  == @mailto }
      assert { MailHistory.last.key == 'sendgrid_mailer_test' }
      assert { MailHistory.last.sent_at.is_a? Time }
      assert { MailHistory.last.attachment_summary == %|[{"content_id":"example1","mime_type":"image/png","filename":"example1.png","size":277}]| }
      refute { MailHistory.last.error? } # No error until checking error
    end
  end
end
