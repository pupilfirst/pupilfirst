class AddPublishedToNews < ActiveRecord::Migration[4.2]
  def change
    add_column :news, :published_at, :timestamp
  end
end
