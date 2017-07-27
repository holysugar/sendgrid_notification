require 'sendgrid_notification/sendgrid_client'

module SendgridTestHelper
  extend ActiveSupport::Concern

  included do
    setup do
      # suppress many warnings in sendgrid-ruby
      @v = $VERBOSE
      $VERBOSE = false
    end

    teardown do
      $VERBOSE = @v
    end
  end

  def skip_unless_sendgrid_api_key
    SendgridNotification::SendgridClient.new
  rescue => e
    raise MiniTest::Skip, e.to_s, caller
  end
end
