class DropCollegesUniversitiesStatesAndPlatformFeedback < ActiveRecord::Migration[6.0]
  def up
    remove_reference :founders, :college, foreign_key: true
    remove_column :founders, :university_id
    remove_column :founders, :college_text
    drop_table :states
    drop_table :universities
    drop_table :colleges
    drop_table :platform_feedback
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
