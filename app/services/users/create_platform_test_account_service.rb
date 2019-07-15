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
        user = User.where(email: @email, school: @startup.school).first_or_create!
        user.update!(name: @name, title: 'Test Account')

        Rails.logger.info("User with email address '#{@email}' created: ##{user.id}.")

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
  end
end
