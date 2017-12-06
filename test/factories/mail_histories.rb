FactoryBot.define do
  factory :mail_history, class: 'SendgridNotification::MailHistory' do
    sequence(:key) { |n| "key#{n}" }
    sequence(:to) { |n| "test#{n}@example.com" } # use faker?
    sequence(:sent_at) { Time.now }
  end
end
