class AddEmailToFaculty < ActiveRecord::Migration[4.2]
  def change
    add_column :faculty, :email, :string
  end
end
