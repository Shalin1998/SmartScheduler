class AddTimeslotIdToGames < ActiveRecord::Migration
  def change
    add_column :games, :timeslot, :integer
  end
end
