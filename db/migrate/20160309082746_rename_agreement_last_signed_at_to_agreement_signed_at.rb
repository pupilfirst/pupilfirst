class RenameAgreementLastSignedAtToAgreementSignedAt < ActiveRecord::Migration
  def change
    rename_column :startups, :agreement_last_signed_at, :agreement_signed_at
  end
end
