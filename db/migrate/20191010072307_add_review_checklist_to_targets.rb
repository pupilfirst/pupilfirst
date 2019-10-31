class AddReviewChecklistToTargets < ActiveRecord::Migration[6.0]
  def change
    add_column :targets, :review_checklist, :jsonb, default: []
  end
end
