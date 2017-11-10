class AddYoutubeVideoIdToTarget < ActiveRecord::Migration[5.1]
  def change
    add_column :targets, :youtube_video_id, :string
  end
end
