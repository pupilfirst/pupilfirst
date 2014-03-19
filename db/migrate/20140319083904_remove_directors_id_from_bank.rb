class RemoveDirectorsIdFromBank < ActiveRecord::Migration
  def change
    remove_column :banks, :directors_id, :string
  end
end
