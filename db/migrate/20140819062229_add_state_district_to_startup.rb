class AddStateDistrictToStartup < ActiveRecord::Migration[4.2]
  def change
    add_column :startups, :state, :string
    add_column :startups, :district, :string
  end
end
