class RemoveStageFromStartups < ActiveRecord::Migration
  def change
    remove_column :startups, :stage, :string
  end
end
