class AddDownloadsToResource < ActiveRecord::Migration[4.2]
  def change
    add_column :resources, :downloads, :integer, default: 0
  end
end
