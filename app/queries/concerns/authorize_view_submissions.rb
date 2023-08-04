module AuthorizeViewSubmissions
  include ActiveSupport::Concern

  def authorized?
    return false if current_user&.faculty.blank? && current_school_admin.blank?

    return false if course&.school != current_school

    current_school_admin.present? ||
      current_user.faculty.courses.exists?(id: course)
  end
end
