class Community < ApplicationRecord
  belongs_to :school
  has_many :courses, dependent: :restrict_with_error
  has_many :questions, dependent: :restrict_with_error

  validates :slug, format: { with: /\A[a-z0-9\-_]+\z/i }, allow_nil: true
  validates :name, presence: true

  # use name as slug
  include FriendlyId
  friendly_id :name, use: %i[slugged finders]
  normalize_attribute :name
end
