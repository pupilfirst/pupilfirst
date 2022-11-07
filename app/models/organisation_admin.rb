class OrganisationAdmin < ApplicationRecord
  belongs_to :organisation
  belongs_to :user

  delegate :name, :email, :title, to: :user
end
