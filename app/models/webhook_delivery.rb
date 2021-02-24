class WebhookDelivery < ApplicationRecord
  belongs_to :course

  enum event: {
         submission_created: 'submission.created',
         submission_graded: 'submission.graded',
         student_added: 'student.added',
         noop: 'noop' # special event, which does not require webhook delivery
       }
end
