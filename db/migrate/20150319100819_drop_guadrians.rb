class DropGuadrians < ActiveRecord::Migration[4.2]
  def change
    drop_table :guardians
  end
end
