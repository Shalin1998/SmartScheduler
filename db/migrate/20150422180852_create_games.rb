class CreateGames < ActiveRecord::Migration
  def change
    create_table :games do |t|
      t.integer :team_one
      t.integer :team_two
      t.datetime :date_time
      t.string :location
      t.integer :team_one_score, :default => 0
      t.integer :team_two_score, :default => 0
      t.belongs_to :user, index:true
      t.belongs_to :tournament

      t.timestamps null: false
    end
  end
end
