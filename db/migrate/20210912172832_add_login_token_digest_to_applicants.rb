class AddLoginTokenDigestToApplicants < ActiveRecord::Migration[6.1]
  def change
    add_column :applicants, :login_token_digest, :string
  end
end
