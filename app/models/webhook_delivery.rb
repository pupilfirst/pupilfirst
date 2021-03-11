class WebhookDelivery < ApplicationRecord
  belongs_to :course

  enum event: {
         course_archived: 'course.archived',
         course_completed: 'course.completed',
         course_unarchived: 'course.unarchived',
         submission_created: 'submission.created',
         submission_graded: 'submission.graded',
         student_added: 'student.added',
         submission_automatically_verified: 'submission.automatically_verified',
         noop: 'noop' # special event, which does not require webhook delivery
       }
end
