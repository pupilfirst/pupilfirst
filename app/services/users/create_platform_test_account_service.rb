module Users
  class CreatePlatformTestAccountService
    def initialize(email, name, startup)
      @email = email
      @name = name
      @startup = startup
    end

    def execute
      User.transaction do
        # Create the user.
        user = User.where(email: @email).first_or_create!

        Rails.logger.info("User with email address '#{@email}' created: ##{user.id}.")

        create_user_profile(user)

        # Create the founder in the startup.
        founder = Founder.create!(user: user, startup: @startup)

        Rails.logger.info("Founder for user created: ##{founder.id}, and added to Startup##{@startup.id}.")

        # Create a faculty and add as coach for startup.
        faculty = Faculty.create!(
          category: Faculty::CATEGORY_VISITING_COACHES,
          user: user,
          school: @startup.school
        )

        Startups::AssignReviewerService.new(@startup).assign(faculty)

        Rails.logger.info("Faculty for user created: ##{faculty.id}), and added as coach for Startup##{@startup.id}.")
      end
    end

    private

    def create_user_profile(user)
      user_profile = UserProfile.where(user: user, school: @startup.school).first_or_create!
      user_profile.update!(name: @name, title: 'Test Account')
    end
  end
end
