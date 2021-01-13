class RemoveDirectorsIdFromBank < ActiveRecord::Migration[4.2]
  def change
    remove_column :banks, :directors_id, :string
  end
end
