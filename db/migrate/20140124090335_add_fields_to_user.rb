class AddFieldsToUser < ActiveRecord::Migration
  def change
    add_column :users, :title, :string
    add_column :users, :linkedin_url, :string
    add_column :users, :twitter_url, :string
  end
end
