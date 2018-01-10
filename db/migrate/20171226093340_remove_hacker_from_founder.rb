class RemoveHackerFromFounder < ActiveRecord::Migration[5.1]
  def change
    remove_column :founders, :hacker, :boolean
  end
end
