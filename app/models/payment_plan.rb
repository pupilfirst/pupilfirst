class PaymentPlan < ApplicationRecord
  belongs_to :course
  belongs_to :plan, polymorphic: true
end
