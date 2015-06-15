class AddGeneratedToTournaments < ActiveRecord::Migration
  def change
    add_column :tournaments, :generated, :boolean, :default => false
  end
end
