class CreateNewCollegesTable < ActiveRecord::Migration
  def change
    create_table :colleges do |t|
      t.string :name
      t.string :also_known_as
      t.string :city
      t.references :state, index: true
      t.string :established_year
      t.string :website
      t.string :contact_numbers
      t.references :replacement_university, index: true
    end
  end
end
