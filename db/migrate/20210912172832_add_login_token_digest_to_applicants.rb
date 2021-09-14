class AddLoginTokenDigestToApplicants < ActiveRecord::Migration[6.1]
  def change
    add_column :applicants, :login_token_digest, :string
    add_index :applicants, :login_token_digest, unique: true
  end
end
