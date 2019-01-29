# This module is included in:
#   ProspectiveApplicants::RegistrationForm
#
module AdmissionsPrepopulatable
  extend ActiveSupport::Concern

  def prepopulate(user)
    prepopulate_from(user.founders.first)
  end

  def prepopulate_from(entry)
    return if entry.blank?

    self.name = entry.name
    self.email = entry.email
    self.phone = entry.phone
  end
end
