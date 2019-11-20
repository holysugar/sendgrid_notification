class AlterNotificationBodyToMediumtext < ActiveRecord::Migration[5.1]
  def change
    mediumtext = 16777215
    reversible do |dir|
      dir.up do
        change_column :notification_mails, :content, :text, limit: mediumtext
      end

      dir.down do
        change_column :notification_mails, :content, :text
      end
    end
  end
end
