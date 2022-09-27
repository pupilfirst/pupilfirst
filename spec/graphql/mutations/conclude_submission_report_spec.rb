require 'rails_helper'

describe Mutations::ConcludeSubmissionReport, type: :request do
  include TokenAuthHelper

  let(:course) { create :course, :with_cohort }
  let(:student) { create :student, cohort: course.cohorts.first }

  let(:faculty_cohort_enrollment) do
    create :faculty_cohort_enrollment, cohort: course.cohorts.first
  end

  let(:user) { faculty_cohort_enrollment.faculty.user }
  let(:level) { create :level, course: course }
  let(:target_group) { create :target_group, level: level }
  let(:target) { create :target, target_group: target_group }

  let(:submission) do
    create :timeline_event,
           :with_owners,
           latest: true,
           owners: [student],
           target: target
  end

  let(:test_report) { 'This is the test report' }

  before(:each) { @headers = request_spec_headers(user) }

  context 'when the submission report does not exist already' do
    it 'creates a new submission report' do
      expect do
        post(
          '/graphql',
          params: {
            query:
              query(
                submission_id: submission.id,
                test_report: test_report,
                conclusion: 'success'
              )
          },
          as: :json,
          headers: @headers
        )
      end.to change { SubmissionReport.count }.from(0).to(1)

      json = JSON.parse(response.body)
      data = json['data']['concludeSubmissionReport']

      expect(data['success']).to eq(true)

      submission_report = SubmissionReport.find_by(submission_id: submission.id)

      expect(submission_report.completed?).to eq(true)
      expect(submission_report.success?).to eq(true)
      expect(submission_report.test_report).to eq(test_report)
    end
  end

  def query(submission_id:, test_report: nil, conclusion:)
    <<~GQL
      mutation {
        concludeSubmissionReport(
          submissionId: #{submission_id}
          testReport: "#{test_report}"
          conclusion: #{conclusion}
        ) {
          success
        }
      }
    GQL
  end
end
