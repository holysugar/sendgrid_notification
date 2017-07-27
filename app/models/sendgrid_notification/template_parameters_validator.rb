module SendgridNotification
  class TemplateParametersValidator < ActiveModel::Validator
    def initialize(options)
      @parameter_keys ||= Array(options[:parameters]) || []
    end

    def validate(record)
      params = @parameter_keys.map{|k| [k, k] }.to_h
      record.apply(params)
    end
  end
end
