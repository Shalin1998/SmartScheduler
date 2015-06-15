class CreatePlayers < ActiveRecord::Migration
  def change
    create_table :players do |t|
      t.string :name
      t.string :email
      t.belongs_to :team
      t.belongs_to :user

      t.timestamps null: false
    end
  end
end
