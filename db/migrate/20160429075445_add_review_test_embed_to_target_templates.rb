class AddReviewTestEmbedToTargetTemplates < ActiveRecord::Migration[4.2]
  def change
    add_column :target_templates, :review_test_embed, :text
  end
end
