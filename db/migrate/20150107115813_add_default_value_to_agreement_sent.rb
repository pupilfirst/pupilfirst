class AddDefaultValueToAgreementSent < ActiveRecord::Migration[4.2]
  def change
    change_column :startups, :agreement_sent, :boolean, :default => false
  end
end
