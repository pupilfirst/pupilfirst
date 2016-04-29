class AddReviewTestEmbedToTargets < ActiveRecord::Migration
  def change
    add_column :targets, :review_test_embed, :text
  end
end
