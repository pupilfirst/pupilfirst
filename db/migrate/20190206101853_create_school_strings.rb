class CreateSchoolStrings < ActiveRecord::Migration[5.2]
  def change
    create_table :school_strings do |t|
      t.references :school, foreign_key: true, index: false
      t.string :key
      t.text :value

      t.timestamps
    end

    add_index :school_strings, %i[school_id key], unique: true
  end
end
