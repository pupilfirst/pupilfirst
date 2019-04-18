module AuthorizeSchoolAdmin
  include ActiveSupport::Concern

  def authorize
    return if current_school_admin.present?

    raise UnauthorizedMutationException
  end
end
