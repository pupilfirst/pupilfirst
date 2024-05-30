class IsSchoolStandingEnabledResolver < ApplicationQuery
  def is_school_standing_enabled # rubocop:disable Naming/PredicateName
    !!current_school.configuration["enable_standing"]
  end

  def authorized?
    current_school && current_school_admin.present?
  end
end
