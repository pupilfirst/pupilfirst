class UserProfile < ApplicationRecord
  belongs_to :user
  belongs_to :school

  normalize_attribute :gender, :phone, :communication_address, :title, :key_skills, :about,
    :resume_url, :blog_url, :personal_website_url, :linkedin_url, :twitter_url, :facebook_url,
    :angel_co_url, :github_url, :behance_url, :skype_id
end
