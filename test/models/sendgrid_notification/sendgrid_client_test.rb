require 'test_helper'

module SendgridNotification
  class SendgridClientTest < ActiveSupport::TestCase
    include SendgridTestHelper

    test 'sendmail raises error without api_key' do
      prev = Rails.application.config.sendgrid_notification.api_key

      Rails.application.config.sendgrid_notification.api_key = ''
      assert_raise(SendgridClient::Error) { SendgridClient.new }
      Rails.application.config.sendgrid_notification.api_key = prev
    end

    test 'POST send_mail sends email' do
      skip_unless_sendgrid_api_key
      mailto = ENV['MAILTO'] || skip('no mail recipient address(MAILTO)')

      client = SendgridClient.new

      params = {
        from: 'noreply@example.com',
        from_name: 'sendgrid_client unit test',
        to: mailto,
        subject: 'test',
        body: "\u{1F363} Sendgrid mailer テスト!"
      }
      # sendgrid の戻り値のみ確認
      assert { client.mail_send(**params).success? }
    end

    test 'GET suppression_get can get suppression mail information: invalid_emails' do
      skip_unless_sendgrid_api_key

      client = SendgridClient.new
      started = 1.month.ago

      res = client.suppression_get(:invalid_emails, start_time: started, end_time: Time.now, limit: 10)
      assert { res.success? }
      assert { res.body.is_a? Array }
      if res.body.first
        assert { res.body.first.is_a? Hash }
        assert { res.body.first.keys.sort == %w(created email reason) }
        assert { res.body.first['created'] > started.to_i }
        assert { res.body.first['email'].is_a? String }
        assert { res.body.first['reason'].is_a? String }
      end
    end

    test 'GET suppression_get can get suppression mail information: blocks' do
      skip_unless_sendgrid_api_key

      client = SendgridClient.new
      started = 1.month.ago

      res = client.suppression_get(:blocks, start_time: started, end_time: Time.now, limit: 10)
      assert { res.success? }
      assert { res.body.is_a? Array }
      if res.body.first
        assert { res.body.first.is_a? Hash }
        assert { res.body.first.keys.sort == %w(created email reason status) }
        assert { res.body.first['created'] > started.to_i }
        assert { res.body.first['email'].is_a? String }
        assert { res.body.first['reason'].is_a? String }
        assert { res.body.first['status'].yield_self{|s| s == "" || s =~ /\A\d+\.\d+\.\d+\z/ } }
      end
    end

    test 'GET suppression_get is not success if unknown suppression type' do
      skip_unless_sendgrid_api_key

      client = SendgridClient.new
      res = client.suppression_get(:unknown, start_time: 1.day.ago, end_time: Time.now)
      refute { res.success? }
    end
  end
end
