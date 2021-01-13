class AddAboutToUser < ActiveRecord::Migration[4.2]
  def change
    add_column :users, :about, :string
  end
end
