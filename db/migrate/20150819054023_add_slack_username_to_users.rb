class AddSlackUsernameToUsers < ActiveRecord::Migration[4.2]
  def change
    add_column :users, :slack_username, :string
  end
end
