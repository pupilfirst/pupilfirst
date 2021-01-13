class AddRegistrationTypeToStartup < ActiveRecord::Migration[4.2]
  def change
    add_column :startups, :registration_type, :string
  end
end
