class DropSocialIds < ActiveRecord::Migration[4.2]
  def change
    drop_table :social_ids
  end
end
