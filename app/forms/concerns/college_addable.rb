# This module is included in:
#   ProspectiveApplicants::RegistrationForm,
#
module CollegeAddable
  extend ActiveSupport::Concern

  included do
    validates_with CollegeIdOrTextValidator
  end

  def college_details
    if college_text.present?
      { college_text: college_text }
    else
      { college_id: college_id }
    end
  end
end
