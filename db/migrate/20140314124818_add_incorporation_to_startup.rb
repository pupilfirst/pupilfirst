class AddIncorporationToStartup < ActiveRecord::Migration
  def change
    add_column :startups, :dsc, :string
    add_column :startups, :company, :text
    add_column :startups, :authorized_capital, :string
    add_column :startups, :share_holding_pattern, :string
    add_column :startups, :moa, :string
    add_column :startups, :police_station, :text
  end
end
