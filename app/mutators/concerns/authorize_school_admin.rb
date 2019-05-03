module AuthorizeSchoolAdmin
  include ActiveSupport::Concern

  def authorized?
    current_school_admin.present?
  end
end
