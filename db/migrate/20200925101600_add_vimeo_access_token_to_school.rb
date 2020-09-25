class AddVimeoAccessTokenToSchool < ActiveRecord::Migration[6.0]
  def change
    add_column :schools, :vimeo_access_token, :string
  end
end
