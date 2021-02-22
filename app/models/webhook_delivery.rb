class WebhookDelivery < ApplicationRecord
  belongs_to :course

  enum event: {
    submission_created: "submission.created",
    student_added:      "student.added",
  }
end
