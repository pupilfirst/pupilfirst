class AddPrototypelinkToStartup < ActiveRecord::Migration
  def change
    add_column :startups, :prototype_link, :string
  end
end
