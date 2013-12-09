class CreateLocations < ActiveRecord::Migration
  def change
    create_table :locations do |t|
      t.decimal :latitude
      t.decimal :longitude
      t.string :title
      t.text :address

      t.timestamps
    end
  end
end
