class AddPointSystemToTeams < ActiveRecord::Migration
  def change
    add_column :teams, :won, :integer
    add_column :teams, :lost, :integer
    add_column :teams, :draw, :integer
    add_column :teams, :goalsfor, :integer
    add_column :teams, :goalsagainst, :integer
  end
end
