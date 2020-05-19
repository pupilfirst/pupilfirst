module AuthorizeSchoolAdmin
  include ActiveSupport::Concern

  def authorized?
    resource_school == current_school && current_school_admin.present?
  end
end
