class RemoveStartupAdminFromFounder < ActiveRecord::Migration[5.1]
  def change
    remove_column :founders, :startup_admin, :boolean
  end
end
