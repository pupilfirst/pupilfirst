class CoachDashboardPolicy < ApplicationPolicy
  def show?
    record.present? && (enrolled_to_course? || enrolled_to_startups_in_course?)
  end

  private

  def enrolled_to_course?
    FacultyCourseEnrollment.where(course: record, faculty: user.faculty).exists?
  end

  def enrolled_to_startups_in_course?
    FacultyStartupEnrollment.where(startup: record.startups, faculty: user.faculty).exists?
  end
end
