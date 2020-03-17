class BillingAccount < ApplicationRecord
  belongs_to :user
  has_many :billing_plans, dependent: :restrict_with_error
  has_many :billing_beneficiaries, dependent: :restrict_with_error
end
