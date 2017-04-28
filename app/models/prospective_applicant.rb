class ProspectiveApplicant < ApplicationRecord
  belongs_to :college

  # rubocop:disable Rails/FindBy
  def self.with_email(email)
    where('lower(email) = ?', email.downcase).first
  end
  # rubocop:enable Rails/FindBy
end
