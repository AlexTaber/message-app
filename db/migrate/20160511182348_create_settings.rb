class CreateSettings < ActiveRecord::Migration
  def change
    create_table :settings do |t|
      t.integer :user_id, null: false
      t.integer :inactive_time, null: false, default: 10
      t.boolean :email_notifications, null: false, default: true

      t.timestamps null: false
    end
  end
end
