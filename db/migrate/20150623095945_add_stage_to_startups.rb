class AddStageToStartups < ActiveRecord::Migration
  def change
    add_column :startups, :stage, :string
  end
end
