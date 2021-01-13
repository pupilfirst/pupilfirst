class AddReviewTestEmbedToTargets < ActiveRecord::Migration[4.2]
  def change
    add_column :targets, :review_test_embed, :text
  end
end
