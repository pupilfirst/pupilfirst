module QueryAuthorizeSchoolAdmin
  include ActiveSupport::Concern

  def query_authorized?
    resource_school == current_school && current_school_admin.present?
  end
end
