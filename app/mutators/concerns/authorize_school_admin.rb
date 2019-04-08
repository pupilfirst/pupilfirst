module AuthorizeSchoolAdmin
  extend ActiveSupport::Concern

  def must_be_authorized
    return if current_school_admin.present?

    raise 'User is not a school admin'
  end
end
