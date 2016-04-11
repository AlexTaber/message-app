class AddColumnsToTiers < ActiveRecord::Migration
  def change
    add_column :tiers, :monthly_id, :integer
    add_column :tiers, :yearly_id, :integer
  end
end
