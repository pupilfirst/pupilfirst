class AddSocialColumnToStartups < ActiveRecord::Migration
  def change
    add_column :startups, :facebook_link, :string, index: true
    add_column :startups, :twitter_link, :string, index: true
  end
end
