class AddStageToStartups < ActiveRecord::Migration[4.2]
  def change
    add_column :startups, :stage, :string
  end
end
