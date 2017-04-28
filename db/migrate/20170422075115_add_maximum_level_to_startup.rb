class AddMaximumLevelToStartup < ActiveRecord::Migration[5.0]
  def change
    add_reference :startups, :maximum_level, references: :levels, index: true
    add_foreign_key :startups, :levels, column: :maximum_level_id
  end
end
