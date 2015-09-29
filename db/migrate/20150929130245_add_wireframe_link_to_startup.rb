class AddWireframeLinkToStartup < ActiveRecord::Migration
  def change
    add_column :startups, :wireframe_link, :string
  end
end
