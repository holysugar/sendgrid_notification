FactoryBot.define do
  factory :notification_mail, class: 'SendgridNotification::NotificationMail' do
    sequence(:key) { |n| "key#{n}" }
    subject { "Mail Subject" }
    content { "Mail Content" }
  end
end
