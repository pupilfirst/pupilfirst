class BillingPlan < ApplicationRecord
  belongs_to :payment_plan
  belongs_to :billing_account
  has_many :payments, dependent: :restrict_with_error
  has_one :coupon_usage, dependent: :restrict_with_error
end
