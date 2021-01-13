class AddAvatarProcessingToUser < ActiveRecord::Migration[4.2]
  def change
    add_column :users, :avatar_processing, :boolean, default: false
  end
end
