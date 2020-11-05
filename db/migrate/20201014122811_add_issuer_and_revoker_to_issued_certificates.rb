class AddIssuerAndRevokerToIssuedCertificates < ActiveRecord::Migration[6.0]
  def change
    add_reference :issued_certificates, :issuer, foreign_key: { to_table: :users }
    add_reference :issued_certificates, :revoker, foreign_key: { to_table: :users }
    add_column :issued_certificates, :revoked_at, :datetime
  end
end
