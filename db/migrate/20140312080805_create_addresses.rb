class CreateAddresses < ActiveRecord::Migration[4.2]
  def change
    create_table :addresses do |t|
      t.string :flat
      t.string :building
      t.string :street
      t.string :area
      t.string :town
      t.string :state
      t.string :pin

      t.timestamps
    end
  end
end
