require 'test_helper'

module SendgridNotification
  class SendmailJobTest < ActiveJob::TestCase
    setup do
      NullMailer.results.clear
      @notification_mail = create(:notification_mail,
                                  subject: 'notification_mail_test',
                                  content: '[{{ name }}]')
    end

    test 'perform gets sendmail' do
      # this test uses NullMailer. see test/dummy/config/environments/test.rb
      SendmailJob.perform_now('sink@example.com', @notification_mail, {name: 'テスト'})

      assert { NullMailer.results.last }
      last_result = NullMailer.results.last
      assert { last_result.from == 'sendgrid_notification_test@example.com' }
      assert { last_result.to == 'sink@example.com' }
      assert { last_result.subject == 'notification_mail_test' }
      assert { last_result.body == '[テスト]' }
    end
  end
end
