class DropResourcesStartups < ActiveRecord::Migration
  def up
    drop_table :resources_startups
  end

  def down
    create_table :resources_startups do |t|
      t.integer :resource_id, index: true
      t.integer :startup_id, index: true
    end
  end
end
