class ProspectiveApplicant < ApplicationRecord
  belongs_to :college

  scope :with_email, ->(email) { where('lower(email) = ?', email.downcase) }
end
