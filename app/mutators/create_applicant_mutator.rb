class CreateApplicantMutator < ApplicationMutator
  attr_accessor :course_id
  attr_accessor :email

  validates :email, presence: true, length: { maximum: 250 }, email: true
  validates :course_id, presence: { message: 'BlankCourseId' }

  def create_applicant
    Applicant.create!(email: email, course: course)
    true
  end

  private

  def authorized?
    course.present?
  end

  def course
    @course ||= current_school.courses.where(id: course_id).first
  end
end
