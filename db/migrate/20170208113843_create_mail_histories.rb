class CreateMailHistories < ActiveRecord::Migration[5.1]
  def change
    create_table :mail_histories do |t|
      t.string :key, null: false
      t.string :to, null: false
      t.timestamp :sent_at, null: false
      t.string :error_type
      t.text :error_reason

      t.timestamps null: false
    end
  end
end
