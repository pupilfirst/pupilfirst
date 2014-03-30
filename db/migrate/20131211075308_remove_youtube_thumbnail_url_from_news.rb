class RemoveYoutubeThumbnailUrlFromNews < ActiveRecord::Migration
  def change
    remove_column :news, :youtube_thumbnail_url
  end
end
