class AddConnectLinkToFaculty < ActiveRecord::Migration[5.2]
  def change
    add_column :faculty, :connect_link, :string
  end
end
