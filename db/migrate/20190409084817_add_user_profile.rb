class AddUserProfile < ActiveRecord::Migration[5.2]
  def up
    create_table :user_profiles do |t|
      t.references :user, foreign_key: true
      t.references :school, foreign_key: true, index: false

      t.string :name
      t.string :gender
      t.string :phone
      t.string :communication_address

      t.string :title
      t.string :key_skills
      t.text :about

      t.string :resume_url
      t.string :blog_url
      t.string :personal_website_url

      t.string :linkedin_url
      t.string :twitter_url
      t.string :facebook_url
      t.string :angel_co_url
      t.string :github_url
      t.string :behance_url
      t.string :skype_id

      t.timestamps
    end

    add_index :user_profiles, %w[school_id user_id], unique: true
  end

  def down
    drop_table :user_profiles
  end
end
