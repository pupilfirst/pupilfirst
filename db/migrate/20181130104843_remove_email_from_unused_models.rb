class RemoveEmailFromUnusedModels < ActiveRecord::Migration[5.2]
  def change
    remove_column :faculty, :email, :string
    remove_column :admin_users, :email, :string
    remove_column :startups, :email, :string
    remove_column :founders, :email, :string
  end
end
