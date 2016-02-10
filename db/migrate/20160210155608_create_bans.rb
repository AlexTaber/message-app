class CreateBans < ActiveRecord::Migration
  def change
    create_table :bans do |t|
      t.integer :user_id, null: false
      t.date    :expiration, null: false, default: DateTime.now + 2.weeks
      t.boolean :active, null: false, default: true
      t.string  :message, null: false, default: "Your account has been suspended"

      t.timestamps null: false
    end
  end
end
