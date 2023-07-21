require "rails_helper"

RSpec.describe Github::AddSubmissionService, type: :service do
  let(:github_configuration) do
    {
      access_token: "access_token",
      organization_id: "organization_id",
      default_team_id: "default_team_id",
    }
  end

  let!(:school) do
    create(:school, configuration: { github: github_configuration })
  end
  let!(:course) { create(:course, school: school) }
  let(:level) { create(:level, course: course) }
  let(:target_group) { create(:target_group, level: level) }
  let(:target) { create(:target, target_group: target_group) }
  let(:cohort) { create(:cohort, course: course) }
  let!(:student) do
    create(
      :student,
      cohort: cohort,
      github_repository: "organization_id/test_repo",
    )
  end
  let!(:submission) do
    create(:timeline_event, target: target, students: [student])
  end
  let(:service) { described_class.new(submission) }
  let(:octokit_client) { instance_double(Octokit::Client) }
  let(:sha) { "1234567890" }
  let(:action_config) { "test_config" }
  let(:branch_name) { "test_branch" }

  before do
    allow(service).to receive(:github_client).and_return(octokit_client)
  end

  describe "#execute" do
    context "when the GitHub configuration is not present" do
      it "does not perform any action" do
        expect(service).not_to receive(:create_branch)
        service.execute
      end
    end

    context "when the GitHub configuration is present" do
      context "when the action config is not present" do
        it "does not perform any action" do
          expect(service).not_to receive(:create_branch)
          service.execute
        end
      end

      context "when the action config is present but student does not have a repository" do
        let(:setup_repository_service) do
          instance_double(Github::SetupRepositoryService, execute: nil)
        end

        before do
          target.update!(action_config: action_config)
          student.update!(github_repository: nil)
          allow(Github::SetupRepositoryService).to receive(:new).and_return(
            setup_repository_service,
          )
        end

        it "creates a repository for the student" do
          expect(setup_repository_service).to receive(:execute)
          stub_request(
            :get,
            "https://api.github.com/repos/organization_id/student-#{student.id}",
          ).to_return(status: 200, body: "", headers: {})
          expect(service).to receive(:create_branch).and_return(branch_name)
          expect(service).to receive(:ci_file_sha).and_return(sha)
          expect(octokit_client).to receive(:update_contents)
          expect(octokit_client).to receive(:create_contents)

          expect do service.execute end.to change {
            SubmissionReport.count
          }.from(0).to(1)
        end
      end

      context "when the action config is present" do
        before { target.update!(action_config: action_config) }
        it "calls create_branch and add_submission_file methods" do
          expect(service).to receive(:ci_file_sha).and_return(sha)
          expect(service).to receive(:create_branch).and_return(branch_name)
          expect(service).to receive(:add_submission_file).with(
            branch_name,
            student.github_repository,
          )
          expect(octokit_client).to receive(:update_contents).with(
            student.github_repository,
            ".github/workflows/ci.js.yml",
            "Update workflow [skip ci]",
            sha,
            action_config,
            { branch: branch_name },
          )

          expect(octokit_client).to receive(:create_contents).with(
            student.github_repository,
            "submission.json",
            "Add submission data",
            (
              {
                id: submission.id,
                students: [student.id],
                created_at: submission.created_at,
                updated_at: submission.updated_at,
                target_id: submission.target.id,
                checklist: submission.checklist,
                level_number: submission.target.level.number,
                target: {
                  id: target.id,
                  title: target.title,
                  evaluation_criteria: target.evaluation_criteria,
                },
                files: [],
              }
            ).to_json,
            { branch: branch_name },
          )

          service.execute
        end

        it "calls create_branch with re_run" do
          expect(service).to receive(:ci_file_sha).and_return(sha)
          expect(service).to receive(:create_branch).with(true).and_return(
            branch_name,
          )
          expect(octokit_client).to receive(:update_contents)
          expect(octokit_client).to receive(:create_contents)
          service.execute(re_run: true)
        end
      end
    end
  end
end
