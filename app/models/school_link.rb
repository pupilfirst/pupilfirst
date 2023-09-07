class SchoolLink < ApplicationRecord
  belongs_to :school

  KIND_HEADER = -"header"
  KIND_FOOTER = -"footer"
  KIND_SOCIAL = -"social"

  VALID_KINDS = [KIND_HEADER, KIND_FOOTER, KIND_SOCIAL].freeze

  validates :kind, inclusion: VALID_KINDS
  validates :url, presence: true
  validates_with RateLimitValidator, limit: 25, scope: :school_id

  normalize_attribute :title

  validates :title,
            presence: true,
            length: {
              maximum: 24
            },
            if: -> { header_or_footer? }

  def header_or_footer?
    [KIND_HEADER, KIND_FOOTER].include?(kind)
  end
end
