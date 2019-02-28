class SchoolString < ApplicationRecord
  KEYS = {
    coaches_index_subheading: 'coaches_index_subheading',
    library_index_subheading: 'library_index_subheading',
    email_address: 'email_address',
    address: 'address',
    privacy_policy: 'privacy_policy',
    terms_of_user: 'terms_of_use'
  }.freeze

  belongs_to :school

  validates :key, presence: true, inclusion: { in: KEYS.values }
  validates :value, presence: true

  def self.fetch(school, key)
    find_by(school: school, key: key)&.value
  end

  def self.saved?(school, key)
    where(school: school, key: key).exists?
  end
end
