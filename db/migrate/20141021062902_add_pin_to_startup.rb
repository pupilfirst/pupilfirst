class AddPinToStartup < ActiveRecord::Migration[4.2]
  def change
    add_column :startups, :pin, :string
  end
end
