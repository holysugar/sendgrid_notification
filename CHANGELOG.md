# Change Log

## [0.2.1]

### Changes

- (Breaking changes) Change uniqueness validator case_sensitive option
  - `case_sensitive: false`
  - required for `rails >= 6`

## [0.2.0]

### New Features

- (Breaking changes) Enable to attachment files
  - Require Rails version >= `5.2`
  - Add more database table column: `mail_histories.attachment_summary`
  - Change `BaseMailer#sendmail` args
    - `params`: remove default value. can't use as kwargs
    - `attachments`: attachments
  - Change  `SendmailJob#perform` args

### Changes

- (Migration required) About Generating Database Schema
  - sendgrid_status_update_histories.body limit to mysql LONGTEXT
  - notification_mails.content limit to mysql MEDIUMTEXT
  - add index to mail_histories.to
