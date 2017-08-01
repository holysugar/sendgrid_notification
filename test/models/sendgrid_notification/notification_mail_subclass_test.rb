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

    test 'validates that content can receive parameters and that no unresolved variables remain' do
      @m = ExampleMail.first
      assert { @m.valid? }

      @m.content = 'static'
      assert { @m.valid? }

      @m.content = '[{{ name }}]'
      assert { @m.valid? }

      @m.content = '[{{ name }}]{{ email }} {{ tel }}'
      assert { @m.invalid? }
      assert_equal 'has unresolved variables: tel', @m.errors[:content].first

      @m.content = '[{{ name0 }}]{{ email }}'
      assert { @m.invalid? }
      assert_equal 'has unresolved variables: name0', @m.errors[:content].first

      # base class has no validations about content
      base = @m.becomes(NotificationMail)
      assert { base.valid? } # ah!
    end

  end
end
