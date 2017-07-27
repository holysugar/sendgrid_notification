require 'test_helper'

module SendgridNotification
  class SendgridStatusTest < ActiveSupport::TestCase
    include SendgridTestHelper

    setup do
      @mailto = 'test@example.com'
      @mail_sent_at = Time.new(2017, 2, 16, 20, 0, 0).to_i
      @started = Time.new(2017, 2, 1).to_i
      @ended = Time.new(2017, 3, 1).to_i

      @target = create(:mail_history, to: @mailto, sent_at: Time.at(@mail_sent_at))
      @nontarget = create(:mail_history, sent_at: Time.at(@mail_sent_at))

      @mail_address = 'a@example.com'
    end

    def invalid_emails
      [
        [@mail_sent_at + 10, @mail_address, "Mail domain mentioned in email address is unknown"],
        [@mail_sent_at + 50, "b@example.com", "Known bad domain"],
      ].map do |args|
        SendgridStatus::Suppression.new('invalid_emails', *args)
      end
    end

    # mock
    test 'SendgridStatus.retrieve_all gets suppression lists' do
      skip_unless_sendgrid_api_key

      mock = Minitest::Mock.new
      mock.expect(:call, invalid_emails, ['invalid_emails', @started, @ended])
      mock.expect(:call, [], ['bounces', @started, @ended])
      mock.expect(:call, [], ['blocks', @started, @ended])

      SendgridStatus.stub(:retrieve, mock) do
        result = SendgridStatus.retrieve_all(@started, @ended)

        assert { result.is_a? Array }
        assert { result.first.type }
        assert { result.first.created }
        assert { result.first.email }
        assert { result.first.reason }
        assert { result.first.respond_to? :status }

        mock.verify
      end
    end

    test 'update_mail_history updates target error mail history to fill error information' do
      sendgrid_created = @target.sent_at.to_i + 20

      assert { @target.error_type.nil? }
      assert { @nontarget.error_type.nil? }

      SendgridStatus.update_mail_history(@mailto,
        sendgrid_created, 'something', 'something wrong')

      [@target, @nontarget].each(&:reload)
      assert { @target.error_type == 'something' }
      assert { @target.error_reason == 'something wrong' }
      assert { @nontarget.error_type.nil? }
    end

    test 'update_email_history ignores error information about unknown history' do
      sendgrid_created = @target.sent_at.to_i + 20
      SendgridStatus.update_mail_history('unknown@example.com',
        sendgrid_created, 'unknown', 'unknown')

      # assert { MailHistory.where.not(error_type: 'unknown').exists? } だとだめ
      refute { MailHistory.where(error_type: 'unknown').exists? }
    end

    test 'update updates mail history' do
      skip_unless_sendgrid_api_key

      history = create(:mail_history, sent_at: Time.at(@mail_sent_at), to: @mail_address)

      mock = Minitest::Mock.new
      mock.expect(:call, invalid_emails, [@started, @ended])
      SendgridStatus.stub(:retrieve_all, mock) do
        assert { history.error_type.nil? }
        SendgridStatus.update(@started, @ended)
        history.reload
        assert { history.error_type == 'invalid_emails' }
      end
    end

    test 'auto_update updates mail history' do
      skip_unless_sendgrid_api_key

      # 前回の end_at が今回の started
      started = @mail_sent_at - 1200

      create(:sendgrid_status_update_history,
        start_time: @mail_sent_at - 4800, end_time: started, count: 1, body: '[{}]')
      prev_count = SendgridStatusUpdateHistory.count
      history = create(:mail_history, sent_at: Time.at(@mail_sent_at), to: @mail_address)

      now = Time.now

      mock = Minitest::Mock.new
      mock.expect(:call, invalid_emails, [started, now.to_i])

      Time.stub(:now, now) do
        SendgridStatus.stub(:retrieve_all, mock) do
          assert { history.error_type.nil? }
          SendgridStatus.auto_update
          history.reload
          assert { history.error_type == 'invalid_emails' }
          assert { SendgridStatusUpdateHistory.count == prev_count + 1 }
          update_history = SendgridStatusUpdateHistory.last
          assert { update_history.start_time == started }
          assert { update_history.end_time = now.to_i }
          assert { update_history.count == 2 }
          assert { JSON.parse(update_history.body.each_line.first).is_a? Hash } # JSONL format
        end
      end
    end

    test 'Suppression#to_s returns json style string' do
      sup = SendgridStatus::Suppression.new('invalid_emails', 1, 'a@example.com', 'error')
      assert { sup.to_s == '{"type":"invalid_emails","created":1,"email":"a@example.com","reason":"error","status":null}' }
    end
  end
end
