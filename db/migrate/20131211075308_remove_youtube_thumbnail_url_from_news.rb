class RemoveYoutubeThumbnailUrlFromNews < ActiveRecord::Migration[4.2]
  def change
    remove_column :news, :youtube_thumbnail_url
  end
end
