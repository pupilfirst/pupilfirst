class DropSocialIds < ActiveRecord::Migration
  def change
    drop_table :social_ids
  end
end
