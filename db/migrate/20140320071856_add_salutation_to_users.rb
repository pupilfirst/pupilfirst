class AddSalutationToUsers < ActiveRecord::Migration[4.2]
  def change
    add_column :users, :salutation, :string
  end
end
