class RemoveFirstNameAndLastNameFromFounder < ActiveRecord::Migration[5.0]
  def change
    remove_column :founders, :first_name, :string
    remove_column :founders, :last_name, :string
  end
end
