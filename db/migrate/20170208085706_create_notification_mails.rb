class CreateNotificationMails < ActiveRecord::Migration[5.1]
  def change
    create_table :notification_mails do |t|
      t.string :key,     null: false
      t.string :subject, null: false
      t.text   :content, null: false

      t.timestamps null: false
    end

    add_index :notification_mails, :key, unique: true
  end
end
