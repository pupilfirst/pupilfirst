class AddStartupVerifierTokenToUser < ActiveRecord::Migration[4.2]
  def change
    add_column :users, :startup_verifier_token, :string
  end
end
