class AddPictureToNews < ActiveRecord::Migration[4.2]
  def change
    add_column :news, :picture, :string
  end
end
