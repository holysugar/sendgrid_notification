require 'test_helper'

module SendgridNotification
  class NotificationMailTest < ActiveSupport::TestCase
    include ActiveJob::TestHelper

    setup do
      @o = create(:notification_mail, subject: 'notification_mail_test',
                 content: '[{{ name }}]')
    end

    test 'can build' do
      assert { @o.is_a?(NotificationMail) } # first test
    end

    test 'can sendmail_later' do
      to = 'sink@example.com'
      attachments = []
      params = { name: 'TEST', dummy: "DUMMY PARAMS" }

      assert_enqueued_with(job: SendmailJob, args: [to, @o, params, attachments]) do
        @o.sendmail_later(to, params, attachments)
      end
    end

    test 'can sendmail_now' do
      to = 'sink@example.com'
      attachments = []
      params = { name: 'TEST', dummy: 'DUMMY PARAMS' }

      @o.sendmail_now(to, params, attachments)
      assert_no_enqueued_jobs
    end

    test 'can call sendmail' do
      intance = SendgridNotification::NotificationMail.new
      assert { intance.method(:sendmail) == intance.method(:sendmail_later) }
    end

    test '#apply returns apply params to content' do
      assert { @o.apply(name: 'foo') == '[foo]' }
    end

    # backward compatibility...
    test 'can change variables pattern' do
      begin
        NotificationMail.variable_regexp = /\<%=\s*(\w+)\s*%\>/
        m = build(:notification_mail, content: '[<%= name %>]')
        assert { m.apply(name: 'foo') == '[foo]' }
      ensure
        NotificationMail.variable_regexp = NotificationMail::VARIABLE_REGEXP_DEFAULT
      end
    end
  end
end
