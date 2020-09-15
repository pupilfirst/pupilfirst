class CreateCommunityTopicCategories < ActiveRecord::Migration[6.0]
  def change
    create_table :community_topic_categories do |t|
      t.references :community, foreign_key: true, index: true, null: false
      t.string :name, null: false
    end

    add_reference :topics, :community_topic_category, index: true
  end
end
