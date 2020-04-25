class AddDckFileToCubes < ActiveRecord::Migration[6.0]
  def change
    add_column :cubes, :dck_file, :string
  end
end
