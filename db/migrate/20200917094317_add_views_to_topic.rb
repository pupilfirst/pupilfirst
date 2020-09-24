class AddViewsToTopic < ActiveRecord::Migration[6.0]
  def change
    add_column :topics, :views, :int, default: 0
  end
end
