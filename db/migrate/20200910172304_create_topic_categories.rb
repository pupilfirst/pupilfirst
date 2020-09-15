class CreateTopicCategories < ActiveRecord::Migration[6.0]
  def change
    create_table :topic_categories do |t|
      t.references :community, foreign_key: true, index: true, null: false
      t.string :name, null: false
    end

    add_reference :topics, :topic_category, index: true
  end
end
