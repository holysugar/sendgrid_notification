# this file tests subclass of NotificationMail

module SendgridNotification
  class NotificationMailSubclassTest < ActiveSupport::TestCase

    class ExampleMail < NotificationMail
      default_scope -> { where(key: 'registration') }
      validates_with TemplateParametersValidator, parameters: %i(name email)
    end

    include SendgridTestHelper

    setup do
      create(:notification_mail, key: 'other', content: '[{{ val }}]')
      create(:notification_mail, key: 'registration', content: '[{{ name }}]: {{ email }}')
    end

    test 'default_scope' do
      assert { NotificationMail.count == 2 }
      assert { NotificationMail.new.key = '' }

      assert { ExampleMail.count == 1 }
      assert { ExampleMail.new.key == 'registration' }
    end

    test 'validates content can recieve parameters and no unresolved variables remains' do
      @m = ExampleMail.first
      assert { @m.valid? }

      @m.content = 'static'
      assert { @m.valid? }

      @m.content = '[{{ name }}]'
      assert { @m.valid? }

      @m.content = '[{{ name }}]{{ email }} {{ tel }}'
      assert { @m.invalid? }

      @m.content = '[{{ name0 }}]{{ email }}'
      assert { @m.invalid? }

      # base class has no validations about content
      base = @m.becomes(NotificationMail)
      assert { base.valid? } # ah!
    end

  end
end
