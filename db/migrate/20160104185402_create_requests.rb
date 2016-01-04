class CreateRequests < ActiveRecord::Migration
  def change
    create_table :requests do |t|
      t.integer :user_id, null: false
      t.integer :receiver_id, null: false
      t.integer :site_id, null: false

      t.timestamps null: false
    end
  end
end
