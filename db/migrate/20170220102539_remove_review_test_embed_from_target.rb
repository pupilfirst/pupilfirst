class RemoveReviewTestEmbedFromTarget < ActiveRecord::Migration[5.0]
  def change
    remove_column :targets, :review_test_embed, :text
  end
end
