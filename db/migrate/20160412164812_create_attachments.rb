class CreateAttachments < ActiveRecord::Migration
  def change
    create_table :attachments do |t|
      t.string :url, null: false
      t.integer :message_id, null: false

      t.timestamps null: false
    end
  end
end
