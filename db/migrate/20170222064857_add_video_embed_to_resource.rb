class AddVideoEmbedToResource < ActiveRecord::Migration[5.0]
  def change
    add_column :resources, :video_embed, :text
  end
end
