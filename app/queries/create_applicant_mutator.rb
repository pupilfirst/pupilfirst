class CreateApplicantMutator < ApplicationQuery
  property :email, validates: { presence: true, length: { maximum: 128 }, email: true }
  property :course_id, validates: { presence: { message: 'BlankCourseId' } }
  property :name, validates: { presence: true, length: { maximum: 128 } }

  validate :ensure_time_between_requests
  validate :not_a_student
  validate :email_should_not_have_bounced

  def create_applicant
    Applicant.transaction do
      applicant = persisted_applicant || Applicant.create!(email: email, course: course, name: name)

      if context[:session][:applicant_tag].present?
        applicant.tag_list.add(context[:session][:applicant_tag])
        applicant.save!
      end

      # Generate token and send course enrollment email
      applicant.regenerate_login_token
      applicant.update!(login_mail_sent_at: Time.zone.now)
      ApplicantMailer.enrollment_verification(applicant).deliver_now
    end

    true
  end

  private

  def authorized?
    course&.school == current_school
  end

  def persisted_applicant
    @persisted_applicant ||= Applicant.with_email(email).where(course: course).first
  end

  def course
    @course ||= Course.find_by(id: course_id, public_signup: true)
  end

  def ensure_time_between_requests
    return if persisted_applicant&.login_mail_sent_at.blank?

    time_since_last_mail = Time.zone.now - persisted_applicant.login_mail_sent_at

    return if time_since_last_mail > 2.minutes

    errors[:base] << 'An email was sent less than two minutes ago. Please wait for a few minutes before trying again.'
  end

  def not_a_student
    return if course.blank?

    return if course.users.with_email(email).empty?

    errors[:base] << "You are already enrolled in #{course.name} course. Try signing in, instead."
  end

  def email_should_not_have_bounced
    return if BounceReport.where(email: email).blank?

    errors[:base] << "The email address you supplied cannot be used because an email we'd sent earlier bounced"
  end
end
