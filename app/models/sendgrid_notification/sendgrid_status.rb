require 'sendgrid-ruby'

module SendgridNotification
  class SendgridStatus
    class RetrieveError < ::StandardError; end

    # mapped to sendgrid api result
    # e.g. https://sendgrid.com/docs/API_Reference/Web_API_v3/blocks.html
    # ( なお invalid_emails には status がない。そもそも送っていないから。 )
    Suppression = Struct.new(:type, :created, :email, :reason, :status) do
      def self.build(type, hash)
        new(type, *hash.values_at('created', 'email', 'reason', 'status'))
      end

      def to_s
        to_h.to_json
      end
    end

    def self.auto_update(ignore_errors: false)
      last_end_time = SendgridNotification::SendgridStatusUpdateHistory.order(:id).reverse_order.limit(1).pluck(:end_time).first
      start_time = last_end_time || 1.hour.ago.to_i
      end_time = Time.now.to_i

      suppressions = update(start_time, end_time)

      begin
        SendgridStatusUpdateHistory.create!(
          start_time: start_time,
          end_time: end_time,
          count: suppressions.size,
          body: suppressions.map(&:to_s).join("\n")
        )
      rescue => e
        if ignore_errors
          warn "#{e} (ignored)"
          SendgridStatusUpdateHistory.create(
            start_time: start_time,
            end_time: end_time,
            count: suppressions.size,
            body: "" # ignored
          )
        else
          raise
        end
      end
    end

    # TODO: 前回の保存日時からの内容を記録
    def self.update(start_time = 1.hour.ago, end_time = Time.now)
      suppressions = retrieve_all(start_time, end_time)
      suppressions.each do |s|
        update_mail_history(s.email, s.created, s.type, s.reason)
      end
      suppressions
    end

    def self.retrieve_all(start_time, end_time)
      SendgridClient::SUPPRESSION_TYPES.each_with_object([]) do |type, suppressions|
        result = retrieve(type, start_time, end_time)
        suppressions.concat result
      end
    end

    # type is one of SendgridClient::SUPPRESSION_TYPES
    # {start,end}_time is Time or Integer
    def self.retrieve(type, start_time, end_time, limit = 100)
      _client = client
      offset = 0
      suppressions = []
      begin
        res = _client.suppression_get(type,
                start_time: start_time.to_i, end_time: end_time.to_i,
                limit: limit, offset: offset)
        # FIXME: if timeout?
        if res.success?
          # res.body is type of [{}]
          results = res.body.map { |h| Suppression.build(type.to_s, h) }
          suppressions.concat results
        else
          # Rails.logger.warn "sendgrid returns status code #{res.status_code}. (#{type}, #{start_time}, #{end_time})"
          raise RetrieveError, "sendgrid returns status code #{res.status_code}. (#{type}, #{start_time}, #{end_time})"
        end
        offset += limit
      end while results.size == limit
      suppressions
    end

    def self.client
      SendgridClient.new
    end

    # status_timestamp allows Integer unix timestamp
    def self.update_mail_history(mailto, status_timestamp, error_type, error_reason, relation = MailHistory.all)
      target = relation.order(:sent_at).where(to: mailto).where('sent_at <= ?', Time.at(status_timestamp)).first
      if target
        target.update!(error_type: error_type, error_reason: error_reason)
      else
        Rails.logger.warn("SendgridStatus::Updater#update: Fail to find history; mailto: #{mailto}, created: #{status_timestamp}, error_type: #{error_type}, error_reason: #{error_reason}")
      end
    end
  end
end
