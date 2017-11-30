module SendgridNotification
  class SendgridMailerTest < ActiveSupport::TestCase
    include SendgridTestHelper

    setup do
      skip_unless_sendgrid_api_key

      @mailer = SendgridMailer.new(
        mail_from: "admin@example.com",
        mail_from_name: "Taro Yamada"
      )
      @mailto = ENV['MAILTO']

      @mail = create(:notification_mail,
        key: 'sendgrid_mailer_test',
        subject: 'Sendgrid mailer テスト',
        content: "\u{1F363} Sendgrid mailer テスト for {{ name }}! \u{1F355}",)
    end

    # メールを何通も送りたくないので複数のテスト項目をまとめている
    test 'sendmail' do
      skip unless @mailto
      prev_count = MailHistory.count

      @mailer.sendmail(@mailto, @mail, name: ENV['USER'])
      assert { @mailer.from == "admin@example.com" }
      assert { @mailer.from_name == "Taro Yamada" }
      assert { @mailer.last_result_success? }

      assert { MailHistory.count    == prev_count + 1 }
      assert { MailHistory.last.to  == @mailto }
      assert { MailHistory.last.key == 'sendgrid_mailer_test' }
      assert { MailHistory.last.sent_at.is_a? Time }
      refute { MailHistory.last.error? } # 送った瞬間はエラーにはなりえない
    end
  end
end
