class AddIsFounderToStartup < ActiveRecord::Migration[4.2]
  def change
    add_column :users, :is_founder, :boolean
  end
end
