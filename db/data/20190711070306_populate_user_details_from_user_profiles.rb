class PopulateUserDetailsFromUserProfiles < ActiveRecord::Migration[5.2]
  def up
    # Populate data for users in SV School
    sv_school = School.first

    sv_school.user_profiles.each do |user_profile|
      user = user_profile.user
      user.update!(
        school_id: sv_school.id,
        name: user_profile.name,
        gender: user_profile.gender,
        phone: user_profile.phone,
        communication_address: user_profile.communication_address,
        title: user_profile.title,
        key_skills: user_profile.key_skills,
        about: user_profile.about,
        resume_url: user_profile.resume_url,
        blog_url: user_profile.blog_url,
        personal_website_url: user_profile.personal_website_url,
        linkedin_url: user_profile.linkedin_url,
        twitter_url: user_profile.twitter_url,
        facebook_url: user_profile.facebook_url,
        angel_co_url: user_profile.angel_co_url,
        github_url: user_profile.github_url,
        behance_url: user_profile.behance_url,
        skype_id: user_profile.skype_id
      )

      next unless user_profile.avatar.attached?

      ActiveStorage::Attachment.where(
        name: 'avatar',
        record: user
      ).first_or_create!(
        blob: user_profile.avatar.blob
      )
    end

    # Create new users
    School.where.not(id: sv_school).each do |school|
      school.user_profiles.each do |user_profile|
        old_user = user_profile.user
        new_user = school.users.create!(
          email: old_user.email,
          name: user_profile.name,
          gender: user_profile.gender,
          phone: user_profile.phone,
          communication_address: user_profile.communication_address,
          title: user_profile.title,
          key_skills: user_profile.key_skills,
          about: user_profile.about,
          resume_url: user_profile.resume_url,
          blog_url: user_profile.blog_url,
          personal_website_url: user_profile.personal_website_url,
          linkedin_url: user_profile.linkedin_url,
          twitter_url: user_profile.twitter_url,
          facebook_url: user_profile.facebook_url,
          angel_co_url: user_profile.angel_co_url,
          github_url: user_profile.github_url,
          behance_url: user_profile.behance_url,
          skype_id: user_profile.skype_id
        )

        old_user.founders.joins(:school).where(schools: { id: school }).update_all(user: new_user)
        old_user.faculty.where(school: school).update_all(user: new_user)

        next unless user_profile.avatar.attached?

        ActiveStorage::Attachment.where(
          name: 'avatar',
          record: user
        ).first_or_create!(
          blob: user_profile.avatar.blob
        )
      end
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
