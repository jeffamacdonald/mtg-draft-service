class CreateCardsAndCubesTables < ActiveRecord::Migration[6.0]
  def up
    create_table :cards do |t|
    	t.string :name, null: false
    	t.string :cost
    	t.integer :converted_mana_cost
    	t.string :card_text
    	t.string :layout
    	t.integer :power
    	t.integer :toughness
    	t.string :default_image, null: false
    	t.string :color_identity, null: false
    end

    add_index :cards, :name, unique: true
    add_index :cards, :converted_mana_cost
    add_index :cards, :card_text
    add_index :cards, :power
    add_index :cards, :toughness
    add_index :cards, :color_identity

    create_table :card_types do |t|
    	t.references :cards, foreign_key: true
    	t.string :type
    	t.string :sub_type
    	t.string :super_type
    end

    add_index :card_types, :type
    add_index :card_types, :sub_type

    create_table :cubes do |t|
    	t.references :users, foreign_key: true
    	t.string :name, null: false
    	t.datetime :created_at
    	t.datetime :updated_at 
    end

    create_table :cube_cards do |t|
    	t.references :cubes, foreign_key: true
    	t.references :cards, foreign_key: true
    	t.string :set
    	t.string :custom_color_identity
    end
  end

  def down
  	drop_table :cards
  	drop_table :card_types
  	drop_table :cubes
  	drop_table :cube_cards
  end
end
