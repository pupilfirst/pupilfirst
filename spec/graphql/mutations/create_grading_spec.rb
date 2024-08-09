require "rails_helper"

describe Mutations::CreateGrading, type: :request do
  include TokenAuthHelper
  let(:course) { create :course, :with_cohort }
  let(:student) { create :student, cohort: course.cohorts.first }

  let(:faculty_cohort_enrollment) do
    create :faculty_cohort_enrollment, cohort: course.cohorts.first
  end

  let(:user) { faculty_cohort_enrollment.faculty.user }
  let(:level) { create :level, course: course }
  let!(:evaluation_criteria_1) { create :evaluation_criterion, course: course }

  let(:target_group) { create :target_group, level: level }
  let(:target) do
    create :target,
           :with_shared_assignment,
           target_group: target_group,
           given_evaluation_criteria: [evaluation_criteria_1]
  end

  let(:submission) do
    create :timeline_event,
           :with_owners,
           latest: true,
           owners: [student],
           target: target
  end

  before(:each) do
    @headers = request_spec_headers(user)
    Settings.inactive_submission_review_allowed_days = 10
  end

  context "When grading has valid data" do
    it "should evaluate the submission and return success" do
      response_data =
        make_request(
          variables:
            make_variables(
              submission.id,
              [grades(evaluation_criteria_1.id, 2)],
              submission.checklist,
              "Some feedback"
            )
        )

      expect(response_data["data"]["createGrading"]).to eq(
        { "success" => true }
      )
    end
  end

  context "When grading has invalid submission id" do
    it "should return submission not found error" do
      response_data =
        make_request(
          variables:
            make_variables(
              "0",
              [grades(evaluation_criteria_1.id, 2)],
              submission.checklist,
              "some feed back"
            )
        )

      expect(error_message(response_data)).to eq(
        "Unable to find submission with ID: 0, Unable to grade submission without valid evaluation criteria."
      )
    end
  end

  context "When grading has mutated the checklist" do
    it "should return checklist data doesn't match error" do
      response_data =
        make_request(
          variables:
            make_variables(
              submission.id,
              [grades(evaluation_criteria_1.id, 2)],
              [checklist],
              "some feed back"
            )
        )

      expect(error_message(response_data)).to eq(
        "The values for checklist items in the submission does not match with review data"
      )
    end
  end

  context "When grading doesn't have correct shape of the checklist" do
    let!(:invalid_checklist) do
      { checklist: "is not valid", it: "should fail" }
    end
    it "should return invalid checklist shape" do
      response_data =
        make_request(
          variables:
            make_variables(
              submission.id,
              [grades(evaluation_criteria_1.id, 2)],
              checklist,
              "some feed back"
            )
        )

      expect(error_message(response_data)).to eq(
        "The shape of data in the submission checklist does not match the one sent with the review"
      )
    end
  end

  context "When grading has invalid grades" do
    let!(:evaluation_criteria_2) do
      create :evaluation_criterion, course: course
    end
    before do
      target.assignments.first.evaluation_criteria << evaluation_criteria_2
    end
    it "should return invalid grading values error" do
      response_data =
        make_request(
          variables:
            make_variables(
              submission.id,
              [
                grades(evaluation_criteria_1.id, -1),
                grades(evaluation_criteria_2.id, 10)
              ],
              submission.checklist,
              "some feed back"
            )
        )

      expect(error_message(response_data)).to eq(
        'Grading values supplied are invalid: [{"evaluation_criterion_id":"' +
          evaluation_criteria_1.id.to_s +
          '","grade":-1},{"evaluation_criterion_id":"' +
          evaluation_criteria_2.id.to_s + '","grade":10}]'
      )
    end
  end

  context "When grading has invalid evaluation criteria" do
    it "should return invalid grading values error" do
      response_data =
        make_request(
          variables:
            make_variables(
              submission.id,
              [grades(0, 2)],
              submission.checklist,
              "some feed back"
            )
        )

      expect(error_message(response_data)).to eq(
        "Grading values supplied are invalid: [{\"evaluation_criterion_id\":\"0\",\"grade\":2}]"
      )
    end
  end

  context "When submission is already graded" do
    before do
      submission.update!(
        evaluator_id: faculty_cohort_enrollment.faculty.id,
        evaluated_at: Time.zone.now
      )
      TimelineEventGrade.create!(
        timeline_event: submission,
        evaluation_criterion: evaluation_criteria_1,
        grade: 1
      )
    end

    it "should return submission already graded error" do
      response_data =
        make_request(
          variables:
            make_variables(
              submission.id,
              [grades(evaluation_criteria_1.id, 2)],
              submission.checklist,
              "some feed back"
            )
        )

      expect(error_message(response_data)).to eq("Submission already reviewed")
    end
  end

  context "When submission doesn't have evaluation criteria" do
    let!(:submission_without_ec) do
      create :timeline_event, :with_owners, latest: true
    end
    before { submission_without_ec.students << student }
    it "should return cannot grade submission without evaluation criteria" do
      response_data =
        make_request(
          variables:
            make_variables(
              submission_without_ec.id,
              [grades(0, 2)],
              submission_without_ec.checklist,
              "some feed back"
            )
        )

      expect(error_message(response_data)).to eq(
        "Unable to grade submission without valid evaluation criteria."
      )
    end
  end

  context "When submission is archived" do
    before { submission.update!(archived_at: Time.now) }
    it "should return submission has been archived error" do
      response_data =
        make_request(
          variables:
            make_variables(
              submission.id,
              [grades(evaluation_criteria_1.id, 2)],
              submission.checklist,
              "some feed back"
            )
        )

      expect(error_message(response_data)).to eq(
        "Such a submission does not exist, or it has been archived."
      )
    end
  end

  context "When submission owners are inactive" do
    before do
      Settings.inactive_submission_review_allowed_days = 10
      submission.students.first.update!(dropped_out_at: DateTime.now)
      submission.update!(created_at: DateTime.now - 11.days)
    end
    it "should return cannot grade submission of inactive students error" do
      response_data =
        make_request(
          variables:
            make_variables(
              submission.id,
              [grades(evaluation_criteria_1.id, 2)],
              submission.checklist,
              "some feed back"
            )
        )

      expect(error_message(response_data)).to eq(
        "Cannot update inactive student submissions."
      )
    end
  end

  def query()
    <<~'GRAPHQL'
      mutation($submissionId: ID!, $grades: [GradeInput!]!, $checklist: JSON!, $feedback: String) {
        createGrading(submissionId: $submissionId, grades: $grades, checklist: $checklist, feedback: $feedback) {
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

  def make_variables(
    submission_id,
    submission_grades,
    submission_checklist,
    submission_feedback
  )
    {
      submissionId: submission_id.to_s,
      grades: submission_grades,
      checklist: submission_checklist,
      feedback: submission_feedback.to_s
    }.as_json
  end

  def error_message(response_data)
    response_data["errors"][0]["message"]
  end

  def grades(ec_id, grade)
    { evaluationCriterionId: ec_id.to_s, grade: grade }
  end

  def checklist
    {
      title: "checklist title",
      kind: "longText",
      status: "noAnswer",
      result: "this is an answer to the question"
    }
  end
end
