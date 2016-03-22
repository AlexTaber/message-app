class AddCompleterIdToTasks < ActiveRecord::Migration
  def change
    add_column :tasks, :completer_id, :integer
  end
end
