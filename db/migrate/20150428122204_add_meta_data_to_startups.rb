class AddMetaDataToStartups < ActiveRecord::Migration
  def change
    add_column :startups, :metadata, :text
  end
end
