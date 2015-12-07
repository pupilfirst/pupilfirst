class AddTokenToFaculty < ActiveRecord::Migration
  def change
    add_column :faculty, :token, :string
  end
end
