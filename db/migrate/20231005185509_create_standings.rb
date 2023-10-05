class CreateStandings < ActiveRecord::Migration[6.1]
  def change
    create_table :standings do |t|
      t.string :name
      t.string :color
      t.text :description
      t.boolean :default

      t.references :school, null: false, foreign_key: true

      t.timestamps
    end

    add_index :standings, %i[name school_id], unique: true
  end
end
