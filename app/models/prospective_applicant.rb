class ProspectiveApplicant < ApplicationRecord
  belongs_to :college, optional: true

  def self.with_email(email)
    where('lower(email) = ?', email.downcase).first # rubocop:disable Rails/FindBy
  end
end
