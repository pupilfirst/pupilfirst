class DropUserDetailsFromFoundersAndFaculty < ActiveRecord::Migration[5.2]
  def change
    remove_column :faculty, :name,:string
    remove_column :faculty, :title,:string
    remove_column :faculty, :key_skills,:string
    remove_column :faculty, :about,:text
    remove_column :faculty, :linkedin_url,:string
    remove_column :faculty, :slug,:string

    remove_column :founders, :name, :string
    remove_column :founders, :about, :text
    remove_column :founders, :gender, :string
    remove_column :founders, :phone, :string
    remove_column :founders, :communication_address, :text
    remove_column :founders, :permanent_address, :string
    remove_column :founders, :avatar_processing, :boolean
    remove_column :founders, :resume_url, :string
    remove_column :founders, :behance_url,:string
    remove_column :founders, :github_url,:string
    remove_column :founders, :angel_co_url,:string
    remove_column :founders, :facebook_url,:string
    remove_column :founders, :blog_url,:string
    remove_column :founders, :personal_website_url,:string
    remove_column :founders, :twitter_url,:string
    remove_column :founders, :linkedin_url,:string
    remove_column :founders, :skype_id,:string
    remove_column :founders, :slug,:string
  end
end
