class AddPreInvesterNameToStartup < ActiveRecord::Migration[4.2]
  def change
    add_column :startups, :pre_investers_name, :string
  end
end
