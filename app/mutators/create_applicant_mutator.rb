class CreateApplicantMutator < ApplicationMutator
  attr_accessor :course_id
  attr_accessor :email

  validates :email, presence: true, length: { maximum: 128 }, email: true
  validates :course_id, presence: { message: 'BlankCourseId' }

  validate :course_must_exist
  validate :ensure_time_between_requests
  validate :not_a_student

  def save
    Applicant.transaction do
      applicant = persisted_applicant || Applicant.create!(email: email, course: course)
      Applicants::MailLoginTokenService.new(applicant).execute
    end
  end

  private

  def authorized?
    # Anyone can apply
    true
  end

  def persisted_applicant
    @persisted_applicant ||= Applicant.with_email(email).where(course: course).first
  end

  def course
    @course ||= current_school.courses.where(id: course_id, enable_public_signup: true).first
  end

  def course_must_exist
    return if course.present?

    errors[:base] << "The course is not open for public registration"
  end

  def ensure_time_between_requests
    return if persisted_applicant.blank?

    return if persisted_applicant.login_token_sent_at.blank?

    time_since_last_mail = Time.zone.now - persisted_applicant.login_token_sent_at

    return if time_since_last_mail > 2.minutes

    errors[:base] << 'An email was sent less than two minutes ago. Please wait for a few minutes before trying again.'
  end

  def not_a_student
    return if course.blank?

    return unless course.users.where(email: email).any?

    errors[:base] << 'This email is already registered'
  end
end
