class RemoveStaleAgreementColumnsFromStartups < ActiveRecord::Migration
  def change
    remove_column :startups, :agreement_first_signed_at, :datetime
    remove_column :startups, :agreement_ends_at, :datetime
  end
end
