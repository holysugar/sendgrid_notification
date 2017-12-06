require 'sendgrid-ruby'

# monkey patch
class SendGrid::Response
  # about status code, see https://sendgrid.com/docs/API_Reference/Web_API_v3/Mail/errors.html
  def success?
    status_code && status_code.to_i < 300
  end
end

module SendgridNotification
  class SendgridClient
    class Error < RuntimeError; end

    class Response < SendGrid::Response
      attr_reader :raw

      def initialize(send_grid_response) # SendGrid::Response, has status_code, body, headers
        @raw = send_grid_response
      end

      def status_code
        raw.try(:status_code).try(:to_i)
      end

      def success?
        status_code && status_code < 300
      end

      def body
        JSON.parse(raw.body) rescue {}
      end

      delegate :headers, to: :raw
    end

    attr_reader :api_key, :api, :last_response

    delegate :client, to: :api

    def initialize
      @api_key = Rails.application.config.sendgrid_notification.api_key
      if api_key.blank?
        raise Error, "no sendgrid api_key. set config.sendgrid_notification.api_key or " \
                     "SENDGRID_API_KEY environment variable."
      end
      @api = SendGrid::API.new(api_key: api_key)
      @last_response = nil
    end

    # TODO: status_code が 500 系およびタイムアウトのときにリトライできるようにする
    # POST /mail/send
    def mail_send(from:, from_name:, to:, subject:, body:)
      mail = build_mail(from, from_name, to, subject, body)
      res = client.mail._('send').post(request_body: mail.to_json)
      @last_response = Response.new(res)
    end

    SUPPRESSION_TYPES = %w(invalid_emails bounces blocks).freeze

    # GET /suppression/#{type}/
    def suppression_get(suppression_type, start_time:, end_time:, limit: 100, offset: 0)
      unless SUPPRESSION_TYPES.include?(suppression_type.to_s)
        # 警告のみ
        Rails.logger.error("Unknown suppresssion type '#{suppression_type}'")
      end

      params = {
        start_time: start_time.to_i,
        end_time: end_time.to_i,
        limit: limit,
        offset: offset,
      }
      res = client.suppression._(suppression_type).get(query_params: params)
      @last_response = Response.new(res)
    end

    private

    def build_mail(mail_from, mail_from_name, mail_to, subject, body)
      from = SendGrid::Email.new(email: mail_from, name: mail_from_name)
      to = SendGrid::Email.new(email: mail_to)
      content = SendGrid::Content.new(type: 'text/plain', value: body)

      SendGrid::Mail.new(from, subject, to, content)
    end
  end
end
