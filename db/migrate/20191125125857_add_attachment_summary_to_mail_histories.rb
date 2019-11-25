class AddAttachmentSummaryToMailHistories < ActiveRecord::Migration[5.1]
  def change
    add_column :mail_histories, :attachment_summary, :text
  end
end
