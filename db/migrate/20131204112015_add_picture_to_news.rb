class AddPictureToNews < ActiveRecord::Migration
  def change
    add_column :news, :picture, :string
  end
end
