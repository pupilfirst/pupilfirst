class AddPrototypelinkToStartup < ActiveRecord::Migration[4.2]
  def change
    add_column :startups, :prototype_link, :string
  end
end
