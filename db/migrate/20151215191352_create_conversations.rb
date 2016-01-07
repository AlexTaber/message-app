class CreateConversations < ActiveRecord::Migration
  def change
    create_table :conversations do |t|
      t.integer :site_id, null: false
      t.string  :token

      t.timestamps null: false
    end
  end
end
