class RemoveStartupLinkFieldsFromUser < ActiveRecord::Migration
  def up
    remove_columns :users, :startup_link_verifier_id, :startup_verifier_token
  end

  def down
    add_column :users, :startup_verifier_token, :string
    add_column :users, :startup_link_verifier_id, :integer, index: true
  end
end
