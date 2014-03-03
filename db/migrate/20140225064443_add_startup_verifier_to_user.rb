class AddStartupVerifierToUser < ActiveRecord::Migration
  def change
    add_column :users, :startup_link_verifier_id, :integer, index: true
  end
end
