class AddStatusToDrafts < ActiveRecord::Migration[6.0]
  def change
  	remove_index :drafts, :active_status
  	remove_column :drafts, :active_status
  	add_column :drafts, :status, :string, null: false
  	add_index :drafts, :status
  end
end
