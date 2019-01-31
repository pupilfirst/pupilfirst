class RemoveAgreementFieldsFromStartups < ActiveRecord::Migration[5.2]
  def change
    remove_column :startups, :agreement_signed_at, :datetime
    remove_column :startups, :agreements_verified, :boolean
  end
end
