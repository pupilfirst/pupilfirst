module AuthorizeViewSubmissions
  include ActiveSupport::Concern

  def authorized?
    return false if current_user&.faculty.blank?

    return false if course&.school != current_school

    current_user.faculty.courses.exists?(id: course) ||
      current_school_admin.present?
  end
end
