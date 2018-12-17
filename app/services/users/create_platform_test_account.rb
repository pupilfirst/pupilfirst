module Users
  class CreatePlatformTestAccount
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

        # Create the founder in the startup.
        founder = Founder.create!(user: user, name: @name, startup: @startup)

        Rails.logger.info("Founder for user created: ##{founder.id}, and added to Startup##{@startup.id}.")

        # Create a faculty and add as coach for startup.
        faculty = Faculty.create!(
          name: @name,
          title: 'Test Account',
          category: Faculty::CATEGORY_VISITING_COACHES,
          image: Rails.root.join('spec', 'support', 'uploads', 'faculty', 'human.png').open,
          inactive: true,
          user: user
        )

        @startup.faculty << faculty

        Rails.logger.info("Faculty for user created: ##{faculty.id}), and added as coach for Startup##{@startup.id}.")
      end
    end
  end
end
