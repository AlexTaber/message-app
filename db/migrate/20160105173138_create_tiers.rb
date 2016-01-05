class CreateTiers < ActiveRecord::Migration
  def change
    create_table :tiers do |t|
      t.string  :name, null: false
      t.integer :admin_sites, null: false
      t.integer :users_per_site, null: false

      t.timestamps
    end
  end
end
