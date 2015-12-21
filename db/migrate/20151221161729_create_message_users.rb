class CreateMessageUsers < ActiveRecord::Migration
  def change
    create_table :message_users do |t|
      t.integer :user_id, null: false
      t.integer :message_id, null: false
      t.boolean :read, null: false, default: false

      t.timestamps null: false
    end
  end
end
