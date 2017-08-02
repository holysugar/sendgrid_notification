# SendgridNotification

SendgridNotification is engine of Ruby on Rails, and
notification mail (e.g. account registration, logging in by new devise,
reminder, etc...) sender and utility, using SendGrid API.

This provides mail utility models, migrations, and rake tasks.

## Installation / Usage

First, add sendgird_notification in Gemfile

```ruby
gem 'sendgrid_notification'
```

```sh
bundle install
```

Then, generate migration files and migrate

```sh
bin/rails sendgrid_notification_engine:install:migrations
bin/rails db:migrate
```

Generate and edit controllers for NotificationMail CRUD

```
...
```

Create NotificationMail record. key = 'example'


```
...
```

And send the mail

```
...
```

Oops. It lacks SendGrid API configuration. Get API key from sendgrid.com and set it ENV['SENDGRID_API_KEY']


```
...
```

### Make subclasses for each notification_mail key

```
...
```

### Validate mail template has right parameter name

```
...
```

## Configuration

| Name | Description | Default Value |
|------|-------------|---------------|
| config.sendgrid_notification.api_key | SendGrid API Key | `ENV['SENDGRID_API_KEY']` |
| config.sendgrid_notification.mail_from | FROM address of notification mail | `ENV['SENDGRID_MAIL_FROM']` |
| config.sendgrid_notification.mail_from_name | FROM name of notification mail | `ENV['SENDGRID_MAIL_FROM_NAME']` |
| config.sendgrid_notification.mailer | Mailer class name (by string). usually no need to change | `"SendgridNotification::SendgridMailer"` |

## Rake tasks

| Task | Description | ENV/Parameter  |
|------|-------------|----------------|
| sendgrid_notification:send | Send mail  | TO=[recipient email address] KEY=[mail type key] ... and mail parameters  |
| sendgrid_notification:status:autoupdate | Update status from previous autoupdate task | |
| sendgrid_notification:status:retrieve   | Only retrieve suppression statuses in start..end | start=[datetime] end=[datetime] |
| sendgrid_notification:status:update     | Retrieve suppression status and update record | start=[datetime] end=[datetime] |
| sendgrid_notification:testmail:init | Create notification_mails test record. default key = "_test" |
| sendgrid_notification:testmail:send | Send testmail | TO=[recipient email address] [body=body] |

## Contributing

Contribution directions go here.

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
