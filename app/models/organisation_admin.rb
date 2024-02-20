class OrganisationAdmin < ApplicationRecord
  belongs_to :organisation
  belongs_to :user

  validates_with RateLimitValidator, limit: 100, scope: :organisation_id

  delegate :name, :email, :title, to: :user
end
