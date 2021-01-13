class RenameAgreementLastSignedAtToAgreementSignedAt < ActiveRecord::Migration[4.2]
  def change
    rename_column :startups, :agreement_last_signed_at, :agreement_signed_at
  end
end
