class CreatePasswordRecoveries < ActiveRecord::Migration
  def change
    create_table :password_recoveries do |t|
      t.integer :user_id, null: false
      t.string  :token

      t.timestamps null: false
    end
  end
end
