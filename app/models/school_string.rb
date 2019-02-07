class SchoolString < ApplicationRecord
  KEY_COACHES_INDEX_SUBHEADING = -'coaches_index_subheading'

  belongs_to :school

  def self.valid_school_string_keys
    [KEY_COACHES_INDEX_SUBHEADING]
  end

  validates :key, presence: true, inclusion: { in: valid_school_string_keys }
  validates :value, presence: true
end
