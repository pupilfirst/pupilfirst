class AddReviewTestEmbedToTargetTemplates < ActiveRecord::Migration
  def change
    add_column :target_templates, :review_test_embed, :text
  end
end
