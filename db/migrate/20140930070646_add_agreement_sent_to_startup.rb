class AddAgreementSentToStartup < ActiveRecord::Migration
  def change
    add_column :startups, :agreement_sent, :boolean
  end
end
