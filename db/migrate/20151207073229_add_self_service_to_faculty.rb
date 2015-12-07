class AddSelfServiceToFaculty < ActiveRecord::Migration
  def change
    add_column :faculty, :self_service, :boolean
  end
end
