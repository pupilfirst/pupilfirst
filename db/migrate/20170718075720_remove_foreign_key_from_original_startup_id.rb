class RemoveForeignKeyFromOriginalStartupId < ActiveRecord::Migration[5.1]
  def up
    remove_foreign_key :payments, column: :original_startup_id
  end

  def down
    add_foreign_key :payments, :startups, column: :original_startup_id
  end
end
