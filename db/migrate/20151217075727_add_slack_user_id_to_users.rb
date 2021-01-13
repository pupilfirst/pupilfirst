class AddSlackUserIdToUsers < ActiveRecord::Migration[4.2]
  def change
    add_column :users, :slack_user_id, :string
  end
end
