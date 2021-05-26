module Courses
  class EnrollmentForm < Reform::Form
    property :email, virtual: true, validates: { presence: true, email: true }
    property :name,
             virtual: true,
             validates: {
               presence: true,
               length: {
                 maximum: 128
               }
             }

    validate :ensure_time_between_requests
    validate :not_a_student
    validate :email_should_not_have_bounced

    def create_applicant(session)
      Applicant.transaction do
        applicant =
          persisted_applicant ||
            Applicant.create!(email: email, course: model, name: name)

        if session[:applicant_tag].present?
          applicant.tag_list.add(session[:applicant_tag])
          applicant.save!
        end

        # Generate token and send course enrollment email
        applicant.regenerate_login_token
        applicant.update!(login_mail_sent_at: Time.zone.now)

        # Send an email to the applicant.
        ApplicantMailer.enrollment_verification(applicant).deliver_now

        applicant
      end
    end

    private

    def persisted_applicant
      return if email.blank?

      @persisted_applicant ||=
        Applicant.with_email(email).where(course: model).first
    end

    def ensure_time_between_requests
      return if persisted_applicant&.login_mail_sent_at.blank?

      time_since_last_mail =
        Time.zone.now - persisted_applicant.login_mail_sent_at

      return if time_since_last_mail > 2.minutes

      errors[:base] <<
        'An email was sent less than two minutes ago. Please wait for a few minutes before trying again.'
    end

    def not_a_student
      return if model.users.with_email(email).empty?

      errors[:base] <<
        "You are already enrolled in #{model.name} course. Try signing in, instead."
    end

    def email_should_not_have_bounced
      return if BounceReport.where(email: email).blank?

      errors[:base] <<
        "The email address you supplied cannot be used because an email we'd sent earlier bounced"
    end
  end
end
