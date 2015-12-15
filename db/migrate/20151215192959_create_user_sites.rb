class CreateUserSites < ActiveRecord::Migration
  def change
    create_table :user_sites do |t|
      t.integer :site_id, null: false
      t.integer :user_id, null: false

      t.timestamps null: false
    end
  end
end
