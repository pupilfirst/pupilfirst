class RemoveAboutFromStartup < ActiveRecord::Migration[4.2]
  def change
    remove_column :startups, :about, :text
  end
end
