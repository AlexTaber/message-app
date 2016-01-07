class CreateSites < ActiveRecord::Migration
  def change
    create_table :sites do |t|
      t.string :name, null: false
      t.string :url, null: false
      t.string :token

      t.timestamps
    end
  end
end
