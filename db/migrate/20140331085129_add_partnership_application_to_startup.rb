class AddPartnershipApplicationToStartup < ActiveRecord::Migration[4.2]
  def change
    add_column :startups, :partnership_application, :boolean
  end
end
