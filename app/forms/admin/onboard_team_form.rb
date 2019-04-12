module Admin
  class OnboardTeamForm < Reform::Form
    property :member_1_name, validates: { presence: true }
    property :member_1_email, validates: { presence: true }
    property :member_2_name
    property :member_2_email
    property :member_3_name
    property :member_3_email
    property :member_4_name
    property :member_4_email
    property :team_name, validates: { presence: true }
    property :course_id, validates: { presence: true }

    def save
      Founder.transaction do
        team = Startup.create!(name: team_name, level: level)
        member_details.each do |name, email|
          next if name.blank? || email.blank?

          member = user(email)

          user_profile = UserProfile.first_or_create!(user: member, school: level.course.school)
          user_profile.update!(name: name)

          Founder.create!(user: member, startup: team)
        end
        team
      end
    end

    private

    def level
      Course.find(course_id).levels.find_by(number: 1)
    end

    def user(email)
      u = User.where(email: email).first_or_create!
      u.regenerate_login_token if u.login_token.blank?
      u
    end

    def member_details
      {
        member_1_name => member_1_email,
        member_2_name => member_2_email,
        member_3_name => member_3_email,
        member_4_name => member_4_email
      }
    end
  end
end
