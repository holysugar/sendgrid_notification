module SendgridNotification
  class SendgridStatusUpdateHistory < ActiveRecord::Base
    with_options numericality: { only_integer: true } do
      validates :start_time
      validates :end_time
    end

    def start_time_in_time_zone
      Time.zone.at(start_time)
    end

    def end_time_in_time_zone
      Time.zone.at(end_time)
    end
  end
end
