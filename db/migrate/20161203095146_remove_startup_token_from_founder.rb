class RemoveStartupTokenFromFounder < ActiveRecord::Migration[5.0]
  def change
    remove_index :founders, :startup_token
    remove_column :founders, :startup_token, :string
  end
end
