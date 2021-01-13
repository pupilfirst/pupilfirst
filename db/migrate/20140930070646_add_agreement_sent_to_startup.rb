class AddAgreementSentToStartup < ActiveRecord::Migration[4.2]
  def change
    add_column :startups, :agreement_sent, :boolean
  end
end
