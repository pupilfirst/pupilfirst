class CreateTargets < ActiveRecord::Migration
  def change
    create_table :targets do |t|
      t.string :role
      t.references :startup, index: true
      t.references :assigner, index: true # AdminUser
      t.references :timeline_event_type, index: true
      t.string :title
      t.string :short_description
      t.string :resource_url

      t.timestamps null: false
    end
  end
end
