class AddStartupVerifierTokenToUser < ActiveRecord::Migration
  def change
    add_column :users, :startup_verifier_token, :string
  end
end
