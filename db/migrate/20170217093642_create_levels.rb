class CreateLevels < ActiveRecord::Migration[5.0]
  def change
    create_table :levels do |t|
      t.string :name
      t.text :description
      t.integer :number

      t.timestamps
    end
    add_index :levels, :number
  end
end
