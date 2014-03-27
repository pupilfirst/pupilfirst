class AddPreInvesterNameToStartup < ActiveRecord::Migration
  def change
    add_column :startups, :pre_investers_name, :string
  end
end
