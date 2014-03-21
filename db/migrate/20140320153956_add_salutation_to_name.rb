class AddSalutationToName < ActiveRecord::Migration
  def change
    add_column :names, :salutation, :string
  end
end
