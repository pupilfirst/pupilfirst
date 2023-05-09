require 'rails_helper'

RSpec.describe Github::AddSubmissionService, type: :service do
  let(:github_configuration) do
    {
      access_token: 'access_token',
      organization_id: 'organization_id',
      team_id: 'team_id'
    }
  end

  let(:school) { create(:school, configuration: { github: github_configuration }) }
  let(:course) { create(:course, school: school) }
  let(:level) { create(:level, course: course) }
  let(:target_group) { create(:target_group, level: level) }
  let(:target) { create(:target, target_group: target_group) }
  let(:cohort) { create(:cohort, course: course) }
  let(:founder) { create(:founder, cohort: cohort, github_repository: 'organization_id/test_repo') }
  let(:submission) { create(:timeline_event, target: target, founders: [founder]) }
  let(:service) { described_class.new(submission) }
  let(:octokit_client) { instance_double(Octokit::Client) }

  before do
    allow(service).to receive(:github_client).and_return(octokit_client)
  end

  describe '#execute' do
    context 'when the GitHub configuration is not present' do
      it 'does not perform any action' do
        expect(service).not_to receive(:create_branch)
        service.execute
      end
    end

    context 'when the GitHub configuration is present' do
      let(:github_config_instance) { instance_double(Schools::Configuration::Github) }

      before do
        allow(Schools::Configuration::Github).to receive(:new).and_return(github_config_instance)
        allow(github_config_instance).to receive(:configured?).and_return(true)
      end

      context 'when the action config is not present' do
        it 'does not perform any action' do
          expect(service).not_to receive(:create_branch)
          service.execute
        end
      end

      context 'when the action config is present' do
        before do
          target.update!(action_config: 'test_config')
        end

        it 'calls create_branch and add_submission_file methods' do
          expect(service).to receive(:create_branch).and_return('test_branch')
          expect(service).to receive(:add_submission_file).with('test_branch', founder.github_repository)

          service.execute
        end
      end

      context 'when the re_run flag is true' do
        it 'calls create_branch with re_run and add_submission_file methods' do
          expect(service).to receive(:create_branch).with(true)
          expect(service).to receive(:add_submission_file)

          service.execute(re_run: true)
        end
      end
    end
  end
end
