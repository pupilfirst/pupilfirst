class RemoveTitleFromFounders < ActiveRecord::Migration
  def change
    remove_column :founders, :title, :string
  end
end
