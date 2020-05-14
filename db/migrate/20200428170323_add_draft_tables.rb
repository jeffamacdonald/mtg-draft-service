class AddDraftTables < ActiveRecord::Migration[6.0]
  def change
  	create_table :drafts do |t|
  		t.references :cube, references: :cubes, foreign_key: { to_table: :cubes }
      t.string :name, null: false
  		t.boolean :active_status, null: false
  		t.integer :rounds, null: false
  		t.integer :timer_minutes
  		t.timestamps null: false
  	end

    add_index :drafts, :name
  	add_index :drafts, :active_status

  	create_table :draft_participants do |t|
  		t.references :draft, references: :drafts, foreign_key: { to_table: :drafts }
  		t.references :user, references: :users, foreign_key: { to_table: :users }
      t.references :surrogate_user, references: :users, foreign_key: { to_table: :users }
  		t.string :display_name
  		t.integer :draft_position
  		t.timestamps null: false
  	end

    add_index :draft_participants, [:draft_id, :draft_position], unique: true
    add_index :draft_participants, [:draft_id, :user_id], unique: true

  	create_table :participant_picks do |t|
  		t.references :draft_participant, references: :draft_participants, foreign_key: { to_table: :draft_participants }
  		t.references :cube_card, references: :cube_cards, foreign_key: { to_table: :cube_cards }
  		t.integer :pick_number, null: false
  		t.integer :round, null: false
  		t.timestamps null: false
  	end

  	add_index :participant_picks, :round
  end
end
