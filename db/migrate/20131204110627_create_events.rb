class CreateEvents < ActiveRecord::Migration
  def change
    create_table :events do |t|
      t.string :title
      t.text :description
      t.timestamp :start_at
      t.timestamp :end_at
      t.references :location, index: true
      t.boolean :featured
      t.references :category, index: true

      t.timestamps
    end
  end
end
