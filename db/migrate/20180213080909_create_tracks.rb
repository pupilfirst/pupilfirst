class CreateTracks < ActiveRecord::Migration[5.1]
  def change
    create_table :tracks do |t|
      t.string :name
      t.integer :sort_index, default: 0

      t.timestamps
    end
  end
end
