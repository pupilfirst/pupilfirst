class SchoolString < ApplicationRecord
  KEYS = {
    coaches_index_subheading: 'coaches_index_subheading',
    library_index_subheading: 'library_index_subheading',
    school_email_address: 'school_email_address'
  }.freeze

  belongs_to :school

  validates :key, presence: true, inclusion: { in: KEYS.values }
  validates :value, presence: true
end
