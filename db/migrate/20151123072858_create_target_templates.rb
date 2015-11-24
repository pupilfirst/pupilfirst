class CreateTargetTemplates < ActiveRecord::Migration
  def change
    create_table :target_templates do |t|
      t.integer :days_from_start
      t.string :role
      t.string :title
      t.string :short_description
      t.string :completion_instructions
      t.string :resource_url

      t.timestamps null: false
    end
  end
end
