class RenameProductVideoToProductVideoLink < ActiveRecord::Migration
  def change
    rename_column :startups, :product_video, :product_video_link
  end
end
