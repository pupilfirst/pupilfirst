class DropPlatformFeedback < ActiveRecord::Migration[6.0]
  def up
    drop_table :platform_feedback
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
