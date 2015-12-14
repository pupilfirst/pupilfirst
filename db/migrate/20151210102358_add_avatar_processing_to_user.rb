class AddAvatarProcessingToUser < ActiveRecord::Migration
  def change
    add_column :users, :avatar_processing, :boolean, default: false
  end
end
