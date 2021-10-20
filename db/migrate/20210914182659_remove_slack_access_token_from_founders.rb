class RemoveSlackAccessTokenFromFounders < ActiveRecord::Migration[6.1]
  def change
    remove_column :founders, :slack_access_token, :string
  end
end
