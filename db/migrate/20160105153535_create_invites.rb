class CreateInvites < ActiveRecord::Migration
  def change
    create_table :invites do |t|
      t.integer :user_id, null: false
      t.string  :email, null: false
      t.integer :site_id, null: false
      t.string  :token

      t.timestamps null: false
    end
  end
end
