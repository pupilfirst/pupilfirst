class AddTokenToFaculty < ActiveRecord::Migration[4.2]
  def change
    add_column :faculty, :token, :string
  end
end
