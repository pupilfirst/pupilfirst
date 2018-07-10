module Admin
  class OnboardTeamForm < Reform::Form
    property :members, validates: { presence: true }
    property :team_name, validates: { presence: true }
    property :school_id, validates: { presence: true }

    def save
      Founder.transaction do
        team = Startup.create!(product_name: team_name, level: level)
        members.each do |member|
          next if member['email'].blank?
          founder = Founder.where(email: member['email']).first_or_create!(user: user(member['email']))
          founder.update!(name: member['name'], startup: team)
        end
        team
      end
    end

    private

    def level
      School.find(school_id).levels.find_by(number: 1)
    end

    def user(email)
      u = User.with_email(email) || User.create!(email: email)
      u.regenerate_login_token if u.login_token.blank?
      u
    end
  end
end
