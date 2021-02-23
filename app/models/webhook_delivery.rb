class WebhookDelivery < ApplicationRecord
  belongs_to :course

  enum event: {
    submission_created: "submission.created" ,
    submission_graded:  "submission.graded" ,
  }
end
