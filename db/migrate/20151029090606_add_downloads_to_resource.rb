class AddDownloadsToResource < ActiveRecord::Migration
  def change
    add_column :resources, :downloads, :integer, default: 0
  end
end
