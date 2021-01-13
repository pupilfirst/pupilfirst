class AddWireframeLinkToStartup < ActiveRecord::Migration[4.2]
  def change
    add_column :startups, :wireframe_link, :string
  end
end
