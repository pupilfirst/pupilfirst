class CreatePeople < ActiveRecord::Migration
  def change
    create_table :people do |t|
      t.string :first_name
      t.string :last_name
      t.string :middle_name
      t.string :current_occupation
      t.text :educational_qualification
      t.date :place_of_birth

      t.timestamps
    end
  end
end
