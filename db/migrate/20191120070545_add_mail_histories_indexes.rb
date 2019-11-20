class AddMailHistoriesIndexes < ActiveRecord::Migration[5.1]
  def change
    add_index :mail_histories, :to
  end
end
