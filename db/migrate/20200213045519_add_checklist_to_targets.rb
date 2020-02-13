class AddChecklistToTargets < ActiveRecord::Migration[6.0]
  def change
    add_column :targets, :checklist, :jsonb
  end
end
