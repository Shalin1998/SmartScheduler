class AddAvailableToTimeslots < ActiveRecord::Migration
  def change
    add_column :timeslots, :available, :boolean, :default => true
  end
end
