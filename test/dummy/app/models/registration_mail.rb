class RegistrationMail < SendgridNotification::NotificationMail
  default_scope { where(key: 'registration') }

  validates_with SendgridNotification::TemplateParametersValidator, parameters: %i(name)
end
