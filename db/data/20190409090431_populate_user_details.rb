class PopulateUserDetails < ActiveRecord::Migration[5.2]
  def up
    School.all.each do |school|
      school.founders.each do |founder|
        UserProfile.where(school: school, user: founder.user).first_or_create!(
          name: founder.name,
          gender: founder.gender,
          phone: founder.phone,
          communication_address: founder.communication_address,
          about: founder.about,
          resume_url: founder.resume_url,
          blog_url: founder.blog_url,
          personal_website_url: founder.personal_website_url,
          linkedin_url: founder.linkedin_url,
          twitter_url: founder.twitter_url,
          facebook_url: founder.facebook_url,
          angel_co_url: founder.angel_co_url,
          github_url: founder.github_url,
          behance_url: founder.behance_url,
          skype_id: founder.skype_id
        )
      end

      school.faculty.each do |faculty|
        UserProfile.where(school: school, user: faculty.user).first_or_create!(
          name: faculty.name,
          title: faculty.title,
          key_skills: faculty.key_skills,
          about: faculty.about,
          linkedin_url: faculty.linkedin_url,
        )
      end
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
