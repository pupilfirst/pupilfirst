class AddIssuerIdAndRevokedAtToIssuedCertificates < ActiveRecord::Migration[6.0]
  def change
    add_reference :issued_certificates, :issuer
    add_reference :issued_certificates, :revoked_by
    add_column :issued_certificates, :revoked_at, :datetime
  end
end
