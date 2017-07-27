module SendgridNotification
  class Engine < ::Rails::Engine
    config.sendgrid_notification = ActiveSupport::OrderedOptions.new

    initializer "sendgrid_notification.mailer" do |app|
      app.config.sendgrid_notification.mailer ||= "SendgridNotification::SendgridMailer"
      # if test or dev, use NullMailer instead
    end

    initializer "sendgrid_notification.api_key" do |app|
      app.config.sendgrid_notification.api_key ||= ENV['SENDGRID_API_KEY']
    end

    initializer "sendgrid_notification.mail_from" do |app|
      app.config.sendgrid_notification.mail_from ||= ENV['SENDGRID_MAIL_FROM']
      app.config.sendgrid_notification.mail_from_name ||= ENV['SENDGRID_MAIL_FROM_NAME']
    end
  end
end
