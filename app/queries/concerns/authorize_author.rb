module AuthorizeAuthor
  include ActiveSupport::Concern

  def authorized?
    return false if current_user.blank?

    return false if resource_school != current_school

    current_school_admin.present? || current_user.course_authors.where(course: course).present?
  end
end
