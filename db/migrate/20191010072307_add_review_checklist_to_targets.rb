class AddReviewChecklistToTargets < ActiveRecord::Migration[6.0]
  def up
    add_column :targets, :review_checklist, :jsonb, default: []
  end

  def down
    remove_column :targets, :review_checklist
  end
end
