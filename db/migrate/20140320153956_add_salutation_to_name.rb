class AddSalutationToName < ActiveRecord::Migration[4.2]
  def change
    add_column :names, :salutation, :string
  end
end
