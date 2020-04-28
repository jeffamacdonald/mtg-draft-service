class AddCubeCardCompoundIndex < ActiveRecord::Migration[6.0]
  def change
  	add_index :cube_cards, [:cube_id, :card_id], unique: true
  end
end
