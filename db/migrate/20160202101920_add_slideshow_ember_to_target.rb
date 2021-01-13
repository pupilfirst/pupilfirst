class AddSlideshowEmberToTarget < ActiveRecord::Migration[4.2]
  def change
    add_column :targets, :slideshow_embed, :text
  end
end
