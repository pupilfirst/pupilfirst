class AddAgreementFirstSignedAtAndMoreToStartup < ActiveRecord::Migration
  def change
    add_column :startups, :agreement_first_signed_at, :datetime
    add_column :startups, :agreement_last_signed_at, :datetime
    add_column :startups, :agreement_ends_at, :datetime
  end
end
