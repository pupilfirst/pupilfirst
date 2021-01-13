class AddStartupTokenToFounder < ActiveRecord::Migration[4.2]
  def change
    add_column :founders, :startup_token, :string
    add_index :founders, :startup_token
  end
end
