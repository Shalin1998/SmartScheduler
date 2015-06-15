class CreateFields < ActiveRecord::Migration
  def change
    create_table :fields do |t|
      t.belongs_to :user, index: true
      t.string 'name'
      t.string 'location'

      t.timestamps null: false
    end
  end
end
