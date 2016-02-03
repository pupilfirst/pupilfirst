class AddSlideshowEmberToTarget < ActiveRecord::Migration
  def change
    add_column :targets, :slideshow_embed, :text
  end
end
