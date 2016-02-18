class AddSlideshowEmbedToTargetTemplate < ActiveRecord::Migration
  def change
    add_column :target_templates, :slideshow_embed, :text
  end
end
