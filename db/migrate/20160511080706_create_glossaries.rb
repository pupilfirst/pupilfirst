class CreateGlossaries < ActiveRecord::Migration
  def change
    create_table :glossaries do |t|
      t.string :term
      t.string :definition
      t.text :links

      t.timestamps null: false
    end
  end
end
