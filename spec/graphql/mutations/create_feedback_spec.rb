require "rails_helper"

describe Mutations::CreateFeedback, type: :request do
  include TokenAuthHelper

  let(:course) { create :course, :with_cohort }
  let(:student) { create :student, cohort: course.cohorts.first }

  let(:faculty_cohort_enrollment) do
    create :faculty_cohort_enrollment, cohort: course.cohorts.first
  end

  let(:user) { faculty_cohort_enrollment.faculty.user }
  let(:level) { create :level, course: course }
  let(:target_group) { create :target_group, level: level }
  let(:evaluation_criteria_1) { create :evaluation_criterion, course: course }
  let(:form_target) do
    create :target, :with_shared_assignment, target_group: target_group
  end

  let(:form_submission) do
    create :timeline_event,
           :with_owners,
           latest: true,
           owners: [student],
           target: form_target
  end

  before(:each) { @headers = request_spec_headers(user) }

  context "when a feedback is added to form submission" do
    it "creates new feedback and sends the mailer" do
      response =
        make_request(
          variables:
            make_variables(
              submission_id: form_submission.id,
              feedback: "This is a feedback for a form submission using API"
            )
        )

      expect(response.dig("data", "createFeedback", "success")).to eq(true)

      perform_enqueued_jobs

      expect(form_submission.startup_feedback.count).to eq(1)
      expect(form_submission.startup_feedback.last.feedback).to eq(
        "This is a feedback for a form submission using API"
      )

      expect(ActionMailer::Base.deliveries.count).to eq(1)

      open_email(student.email)
      expect(current_email.body).not_to include("rejected")
      expect(current_email.body).to include(
        "This is a feedback for a form submission using API"
      )
    end
  end

  def query
    <<~'GRAPHQL'
    mutation CreateFeedbackMutation($submissionId: ID!, $feedback: String!) {
      createFeedback(submissionId: $submissionId, feedback: $feedback){
        success
      }
    }
    GRAPHQL
  end

  def make_request(variables:)
    post(
      "/graphql",
      params: {
        query: query,
        variables: variables
      },
      as: :json,
      headers: @headers
    )
    JSON.parse(response.body)
  end

  def make_variables(submission_id:, feedback:)
    { submissionId: submission_id, feedback: feedback }
  end
end
