class CreateClaims < ActiveRecord::Migration
  def change
    create_table :claims do |t|
      t.integer :user_id, null: false
      t.integer :task_id, null: false

      t.timestamps null: false
    end
  end
end
