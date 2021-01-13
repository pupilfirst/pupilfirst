class CreateReplacementUniversities < ActiveRecord::Migration[4.2]
  def change
    create_table :replacement_universities do |t|
      t.string :name
      t.references :state, index: true

      t.timestamps null: false
    end
  end
end
