class CreateResourcesStartups < ActiveRecord::Migration[4.2]
  def change
    create_table :resources_startups do |t|
      t.integer :resource_id, index: true
      t.integer :startup_id, index: true
    end
  end
end
