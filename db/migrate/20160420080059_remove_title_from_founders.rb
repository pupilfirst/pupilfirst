class RemoveTitleFromFounders < ActiveRecord::Migration[4.2]
  def change
    remove_column :founders, :title, :string
  end
end
