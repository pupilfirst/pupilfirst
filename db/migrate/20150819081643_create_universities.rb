class CreateUniversities < ActiveRecord::Migration[4.2]
  def change
    create_table :universities do |t|
      t.string :name

      t.timestamps null: false
    end
  end
end
