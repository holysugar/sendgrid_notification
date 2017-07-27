class CreateSendgridStatusUpdateHistories < ActiveRecord::Migration[5.1]
  def change
    create_table :sendgrid_status_update_histories do |t|
      t.integer :start_time, null: false
      t.integer :end_time, null: false
      t.integer :count
      t.text :body

      t.timestamps null: false
    end
  end
end
