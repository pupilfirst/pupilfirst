class RemoveAboutFromStartup < ActiveRecord::Migration
  def change
    remove_column :startups, :about, :text
  end
end
