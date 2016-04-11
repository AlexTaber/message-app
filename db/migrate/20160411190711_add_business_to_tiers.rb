class AddBusinessToTiers < ActiveRecord::Migration
  def change
    add_column :tiers, :business, :boolean
  end
end
