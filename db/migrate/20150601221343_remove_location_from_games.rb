class RemoveLocationFromGames < ActiveRecord::Migration
  def change
    remove_column :games, :location, :string
  end
end
