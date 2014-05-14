class AddRegistrationTypeToStartup < ActiveRecord::Migration
  def change
    add_column :startups, :registration_type, :string
  end
end
