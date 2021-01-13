class RemoveStageFromStartups < ActiveRecord::Migration[4.2]
  def change
    remove_column :startups, :stage, :string
  end
end
