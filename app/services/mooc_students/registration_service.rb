module MoocStudents
  # Perform registration of a MoocStudent
  class RegistrationService
    attr_reader :attributes

    def initialize(attributes)
      @attributes = attributes
    end

    def register
      User.transaction do
        # Find or create the user entry.
        user = User.with_email(attributes[:email]).first
        user = User.create!(email: attributes[:email]) if user.blank?

        # Find or initialize the user entry.
        mooc_student = MoocStudent.where(user_id: user.id).first_or_create!(attributes)

        # Send the user a login email, welcoming him / her to SixWays.
        MoocStudentMailer.welcome(mooc_student).deliver_now

        # Return the user
        user
      end
    end
  end
end
