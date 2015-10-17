class AddEmailToFaculty < ActiveRecord::Migration
  def change
    add_column :faculty, :email, :string
  end
end
