require 'test_helper'

module SendgridNotification
  class MailHistoryTest < ActiveSupport::TestCase
    test '#start_time_in_time_zone' do
      history = build_stubbed(:sendgrid_status_update_history, start_time: 1488789900)
      assert { history.start_time_in_time_zone == Time.zone.parse('2017/3/6 17:45:00 JST') }
    end

    test '#end_time_in_time_zone' do
      history = build_stubbed(:sendgrid_status_update_history, end_time: 1488790200)
      assert { history.end_time_in_time_zone == Time.zone.parse('2017/3/6 17:50:00 JST') }
    end
  end
end
