class RemoveExtraColumnsFromUser < ActiveRecord::Migration[6.0]
  def change
    remove_column :users, :phone, :string
    remove_column :users, :communication_address, :string
    remove_column :users, :key_skills, :string
    remove_column :users, :resume_url, :string
    remove_column :users, :blog_url, :string
    remove_column :users, :personal_website_url, :string
    remove_column :users, :linkedin_url, :string
    remove_column :users, :twitter_url, :string
    remove_column :users, :facebook_url, :string
    remove_column :users, :angel_co_url, :string
    remove_column :users, :github_url, :string
    remove_column :users, :behance_url, :string
    remove_column :users, :skype_id, :string
  end
end
