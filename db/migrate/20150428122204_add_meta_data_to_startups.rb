class AddMetaDataToStartups < ActiveRecord::Migration[4.2]
  def change
    add_column :startups, :metadata, :text
  end
end
