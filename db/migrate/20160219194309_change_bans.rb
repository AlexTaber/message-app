class ChangeBans < ActiveRecord::Migration
  def up
    change_column :bans, :expiration, :date, default: nil
  end
end