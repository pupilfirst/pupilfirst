module MoocStudents
  # Perform registration of a MoocStudent
  class RegistrationService
    attr_reader :attributes

    def initialize(attributes, send_sign_in_email)
      @attributes = attributes
      @send_sign_in_email = send_sign_in_email
    end

    def register
      User.transaction do
        # Find or create the user entry.
        user = User.with_email(attributes[:email])
        user = User.create!(email: attributes[:email]) if user.blank?

        # Find or initialize the user entry.
        mooc_student = MoocStudent.where(user_id: user.id).first_or_create!(
          @attributes.slice(:name, :email, :phone, :gender, :college_id, :college_text, :state, :semester)
        )

        # Send the user a login email, welcoming him / her to SixWays.
        if @send_sign_in_email
          user.regenerate_login_token if user.login_token.blank?
          MoocStudentMailer.welcome(mooc_student).deliver_now
        end

        # Return the user
        user
      end
    end
  end
end
