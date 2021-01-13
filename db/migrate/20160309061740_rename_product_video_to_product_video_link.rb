class RenameProductVideoToProductVideoLink < ActiveRecord::Migration[4.2]
  def change
    rename_column :startups, :product_video, :product_video_link
  end
end
