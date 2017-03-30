class AddLevelZeroColumnsToTarget < ActiveRecord::Migration[5.0]
  def change
    add_column :targets, :key, :string
    add_column :targets, :link_to_complete, :string
    add_column :targets, :submittability, :string, null: false, default: 'resubmittable'

    add_index :targets, :key
  end
end
