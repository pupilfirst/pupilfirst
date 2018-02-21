class RemoveMaximumLevelFromStartup < ActiveRecord::Migration[5.1]
  def up
    remove_reference :startups, :maximum_level, references: :levels, index: true
  end

  def down
    add_reference :startups, :maximum_level, references: :levels, index: true
    add_foreign_key :startups, :levels, column: :maximum_level_id
  end
end
