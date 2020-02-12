module AuthorizeAuthor
  include ActiveSupport::Concern

  def authorized?
    return false if current_user.blank?

    current_school_admin.present? || current_user.course_authors.where(course: course).present?
  end
end
