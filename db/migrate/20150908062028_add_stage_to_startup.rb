class AddStageToStartup < ActiveRecord::Migration
  def change
    add_column :startups, :stage, :string
    add_index :startups, :stage
  end
end
