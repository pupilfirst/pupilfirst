class AddPinToStartup < ActiveRecord::Migration
  def change
    add_column :startups, :pin, :string
  end
end
