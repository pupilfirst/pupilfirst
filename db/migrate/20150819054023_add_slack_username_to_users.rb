class AddSlackUsernameToUsers < ActiveRecord::Migration
  def change
    add_column :users, :slack_username, :string
  end
end
