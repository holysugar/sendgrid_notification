FactoryGirl.define do
  factory :sendgrid_status_update_history, class: 'SendgridNotification::SendgridStatusUpdateHistory' do
    start_time { 2.hour.ago.to_i }
    end_time { 1.hour.ago.to_i }
    count 1
  end
end
