class AddSlideshowEmbedToTargetTemplate < ActiveRecord::Migration[4.2]
  def change
    add_column :target_templates, :slideshow_embed, :text
  end
end
