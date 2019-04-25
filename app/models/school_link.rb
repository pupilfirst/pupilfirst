class SchoolLink < ApplicationRecord
  belongs_to :school

  KIND_HEADER = -'header'
  KIND_FOOTER = -'footer'
  KIND_SOCIAL = -'social'

  VALID_KINDS = [KIND_HEADER, KIND_FOOTER, KIND_SOCIAL].freeze

  validates :kind, inclusion: VALID_KINDS
  validates :url, presence: true

  normalize_attribute :title
end
