class CreateTargetGroups < ActiveRecord::Migration[5.0]
  def change
    create_table :target_groups do |t|
      t.string :name
      t.text :description

      t.timestamps
    end
  end
end
