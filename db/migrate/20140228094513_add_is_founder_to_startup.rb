class AddIsFounderToStartup < ActiveRecord::Migration
  def change
    add_column :users, :is_founder, :boolean
  end
end
