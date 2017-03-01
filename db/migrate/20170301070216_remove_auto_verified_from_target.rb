class RemoveAutoVerifiedFromTarget < ActiveRecord::Migration[5.0]
  def change
    remove_column :targets, :auto_verified, :boolean
  end
end
