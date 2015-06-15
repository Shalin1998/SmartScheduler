class CreateTimeslots < ActiveRecord::Migration
  def change
    create_table :timeslots do |t|
      t.datetime :start
      t.datetime :end
      t.integer :field
      t.belongs_to :user
      t.belongs_to :field

      t.timestamps null: false
    end
  end
end
