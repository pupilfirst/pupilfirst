class AddPartnershipApplicationToStartup < ActiveRecord::Migration
  def change
    add_column :startups, :partnership_application, :boolean
  end
end
