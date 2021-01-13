class DropLocation < ActiveRecord::Migration[4.2]
  def change
    drop_table :locations
  end
end
