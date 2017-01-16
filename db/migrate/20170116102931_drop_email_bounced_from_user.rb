class DropEmailBouncedFromUser < ActiveRecord::Migration[5.0]
  def change
    remove_column :users, :email_bounced, :boolean
  end
end
