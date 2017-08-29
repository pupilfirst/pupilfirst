class AddLinkToResources < ActiveRecord::Migration[5.1]
  def change
    add_column :resources, :link, :string
  end
end
