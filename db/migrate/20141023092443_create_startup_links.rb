class CreateStartupLinks < ActiveRecord::Migration
  def change
    create_table :startup_links do |t|
      t.references :startup, index: true
      t.string :name
      t.string :url
      t.string :description

      t.timestamps
    end
  end
end
