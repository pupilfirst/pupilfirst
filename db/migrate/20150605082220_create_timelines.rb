class CreateTimelines < ActiveRecord::Migration
  def change
    create_table :timelines do |t|
      t.integer :iteration
      t.string :title
      t.text :description
      t.string :type
      t.string :image

      t.timestamps null: false
    end
  end
end
