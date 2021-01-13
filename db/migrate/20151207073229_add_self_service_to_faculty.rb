class AddSelfServiceToFaculty < ActiveRecord::Migration[4.2]
  def change
    add_column :faculty, :self_service, :boolean
  end
end
