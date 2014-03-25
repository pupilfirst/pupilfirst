class AddPreFundsToStartup < ActiveRecord::Migration
  def change
    add_column :startups, :pre_funds, :string
    add_column :startups, :startup_before, :text
    add_column :startups, :help_from_sv, :string
  end
end
