class DropGuadrians < ActiveRecord::Migration
  def change
    drop_table :guardians
  end
end
