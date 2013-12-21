class AddPublishedToNews < ActiveRecord::Migration
  def change
    add_column :news, :published_at, :timestamp
  end
end
