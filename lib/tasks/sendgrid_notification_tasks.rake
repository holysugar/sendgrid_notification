namespace :sendgrid_notification do
  namespace :testmail do
    desc 'Create notification_mails test record, KEY = "_test"'
    task init: :environment do
      key = ENV['KEY'] || '_test'
      SendgridNotification::NotificationMail.find_or_create_by!(key: key) do |m|
        m.subject = 'Test mail subject'
        m.content = <<-EOD
This is test mail.
{{ body }}
        EOD
      end
    end

    desc 'Send testmail (TO=address [body=body])'
    task send: :environment do
      ENV['KEY'] ||= '_test'
      ARGV << 'body=[body parameter expected]' unless ENV['body']
      Rake::Task["sendgrid_notification:send"].invoke
    end
  end

  desc 'Send mail (TO=address KEY=mail_key and describe parameter...)'
  task send: :environment do
    to = ENV.fetch('TO')
    key = ENV.fetch('KEY')
    params = ARGV.each_with_object({}) do |arg, hash|
      hash[Regexp.last_match(1)] = Regexp.last_match(2) if arg =~ /^(\w+)=(.*)$/m
    end

    m = SendgridNotification::NotificationMail.find_by!(key: key)
    m.sendmail(to, params)
  end

  namespace :status do
    desc 'update status (start=datetime end=datetime)'
    task update: :environment do
      start_time = Time.parse ENV.fetch('start')
      end_time   = Time.parse ENV.fetch('end')
      SendgridNotification::SendgridStatus.update(start_time, end_time)
    end

    desc 'update status after previous autoupdate'
    task autoupdate: :environment do
      ignore_errors = !!ENV["IGNORE_ERRORS"]
      SendgridNotification::SendgridStatus.auto_update(ignore_errors: ignore_errors)
    end

    desc 'only retrieve suppression statuses (start=datetime end=datetime)'
    task retrieve: :environment do
      start_time = Time.parse ENV.fetch('start')
      end_time   = Time.parse ENV.fetch('end')
      suppressions = SendgridNotification::SendgridStatus.retrieve_all(start_time, end_time)
      puts suppressions
    end
  end
end
