class CreateReplacementUniversities < ActiveRecord::Migration
  def change
    create_table :replacement_universities do |t|
      t.string :name
      t.references :state, index: true

      t.timestamps null: false
    end
  end
end
