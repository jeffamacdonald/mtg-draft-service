class CreateCardsAndCubesTables < ActiveRecord::Migration[6.0]
  def up
    create_table :cards do |t|
    	t.string :name, null: false
    	t.string :cost
    	t.integer :cmc, null: false
        t.string :color_identity, null: false
        t.string :type_line, null: false
    	t.string :card_text
    	t.string :layout
    	t.integer :power
    	t.integer :toughness
    	t.string :default_image, null: false
        t.string :default_set, null: false
        t.timestamps null: false
    end

    add_index :cards, :name, unique: true
    add_index :cards, :cmc
    add_index :cards, :card_text
    add_index :cards, :power
    add_index :cards, :toughness
    add_index :cards, :color_identity

    create_table :cubes do |t|
    	t.references :user, references: :users, foreign_key: { to_table: :users}
    	t.string :name, null: false
    	t.timestamps null: false
    end

    add_index :cubes, :name

    create_table :cube_cards do |t|
    	t.references :cube, references: :cubes, foreign_key: { to_table: :cubes}
    	t.references :card, references: :cards, foreign_key: { to_table: :cards}
        t.integer :count, null: false
    	t.string :custom_set
        t.string :custom_image
    	t.string :custom_color_identity
        t.boolean :soft_delete, null: false
        t.timestamps null: false
    end

    add_index :cube_cards, :soft_delete
    add_index :cube_cards, :custom_color_identity
    add_index :cube_cards, [:cube_id, :card_id], unique: true
  end

  def down
    remove_column :cubes, :user_id
    remove_column :cube_cards, :cube_id
    remove_column :cube_cards, :card_id
  	drop_table :cards
  	drop_table :cubes
  	drop_table :cube_cards
  end
end
