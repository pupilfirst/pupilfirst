class AddStartupVerifierToUser < ActiveRecord::Migration[4.2]
  def change
    add_column :users, :startup_link_verifier_id, :integer, index: true
  end
end
