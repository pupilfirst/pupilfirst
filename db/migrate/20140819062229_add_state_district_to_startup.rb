class AddStateDistrictToStartup < ActiveRecord::Migration
  def change
    add_column :startups, :state, :string
    add_column :startups, :district, :string
  end
end
