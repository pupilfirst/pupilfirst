class AddDefaultValueToAgreementSent < ActiveRecord::Migration
  def change
    change_column :startups, :agreement_sent, :boolean, :default => false
  end
end
