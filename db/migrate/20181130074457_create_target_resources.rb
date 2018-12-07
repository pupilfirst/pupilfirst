class CreateTargetResources < ActiveRecord::Migration[5.2]
  def change
    create_table :target_resources do |t|
      t.references :target, foreign_key: true, index: false, null: false
      t.references :resource, foreign_key: true, null: false
    end

    add_index :target_resources, [:target_id, :resource_id], unique: true
  end
end
