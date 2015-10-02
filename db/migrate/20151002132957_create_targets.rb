class CreateTargets < ActiveRecord::Migration
  def change
    create_table :targets do |t|
      t.string :role
      t.references :startup, index: true
      t.string :status
      t.string :title
      t.string :short_description
      t.string :resource_url

      t.timestamps null: false
    end
  end
end
