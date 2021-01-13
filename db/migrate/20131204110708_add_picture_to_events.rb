class AddPictureToEvents < ActiveRecord::Migration[4.2]
  def change
    add_column :events, :picture, :string
  end
end
