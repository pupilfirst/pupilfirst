class CoursesResolver < ApplicationQuery
  delegate :courses, to: :current_school

  def authorized?
    current_school_admin.present?
  end

  def allow_token_auth?
    true
  end
end
