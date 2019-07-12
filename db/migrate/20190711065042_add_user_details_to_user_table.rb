class AddUserDetailsToUserTable < ActiveRecord::Migration[5.2]

  def change
    add_column :users, :name, :string
    add_column :users, :phone, :string
    add_column :users, :gender, :string
    add_column :users, :communication_address, :string
    add_column :users, :title, :string
    add_column :users, :key_skills, :string
    add_column :users, :about, :text
    add_column :users, :resume_url, :string
    add_column :users, :blog_url, :string
    add_column :users, :personal_website_url, :string
    add_column :users, :linkedin_url, :string
    add_column :users, :twitter_url, :string
    add_column :users, :facebook_url, :string
    add_column :users, :angel_co_url, :string
    add_column :users, :github_url, :string
    add_column :users, :behance_url, :string
    add_column :users, :skype_id, :string
    add_reference :users, :school, foreign_key: true, index: true
    add_column :admin_users, :email, :string
  end
end
