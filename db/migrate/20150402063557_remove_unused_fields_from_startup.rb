class RemoveUnusedFieldsFromStartup < ActiveRecord::Migration
  def up
    remove_columns :startups, :pre_investers_name, :pre_funds, :startup_before, :company_names, :dsc, :bank_status
    remove_columns :startups, :police_station, :moa, :authorized_capital, :share_holding_pattern, :help_from_sv
    remove_columns :startups, :incorporation_status, :transaction_details, :partnership_application, :total_shares
  end

  def down
    add_column :startups, :pre_investers_name, :string
    add_column :startups, :pre_funds, :string
    add_column :startups, :startup_before, :text
    add_column :startups, :company_names, :text
    add_column :startups, :dsc, :string
    add_column :startups, :bank_status, :boolean, default: false
    add_column :startups, :police_station, :text
    add_column :startups, :moa, :string
    add_column :startups, :authorized_capital, :string
    add_column :startups, :share_holding_pattern, :string
    add_column :startups, :help_from_sv, :string
    add_column :startups, :incorporation_status, :boolean, default: false
    add_column :startups, :transaction_details, :string
    add_column :startups, :partnership_application, :boolean
    add_column :startups, :total_shares, :integer
  end
end
