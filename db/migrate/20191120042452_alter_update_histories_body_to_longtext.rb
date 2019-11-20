class AlterUpdateHistoriesBodyToLongtext < ActiveRecord::Migration[5.1]
  def change
    longtextlimit = 4294967295
    reversible do |dir|
      dir.up do
        change_column :sendgrid_status_update_histories, :body, :text, limit: longtextlimit
      end

      dir.down do
        change_column :sendgrid_status_update_histories, :body, :text
      end
    end
  end
end
