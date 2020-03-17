class BillingBeneficiary < ApplicationRecord
  belongs_to :founder
  belongs_to :billing_account
end
