class AddFieldIdToGames < ActiveRecord::Migration
  def change
    add_column :games, :field_id, :integer
  end
end
