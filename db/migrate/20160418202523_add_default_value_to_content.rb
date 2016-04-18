class AddDefaultValueToContent < ActiveRecord::Migration
  def up
    change_column :messages, :content, :text, :default => "(No Content)"
  end

  def down
    change_column :messages, :content, :text, :default => nil
  end
end
