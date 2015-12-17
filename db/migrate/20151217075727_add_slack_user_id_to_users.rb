class AddSlackUserIdToUsers < ActiveRecord::Migration
  def change
    add_column :users, :slack_user_id, :string
  end
end
