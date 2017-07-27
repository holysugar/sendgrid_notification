Rails.application.routes.draw do
  mount SendgridNotification::Engine => "/sendgrid_notification"
end
