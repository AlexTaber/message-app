class CreateMessages < ActiveRecord::Migration
  def change
    create_table :messages do |t|
      t.integer :user_id, null: false
      t.text    :content, null: false
      t.integer :conversation_id, null: false

      t.timestamps null: false
    end
  end
end
