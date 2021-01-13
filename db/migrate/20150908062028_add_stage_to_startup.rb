class AddStageToStartup < ActiveRecord::Migration[4.2]
  def change
    add_column :startups, :stage, :string
    add_index :startups, :stage
  end
end
