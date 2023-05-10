require 'rails_helper'

RSpec.describe Github::SetupRepositoryService, type: :service do
  let(:github_configuration) do
    {
      access_token: 'access_token',
      organization_id: 'organization_id',
      default_team_id: 'default_team_id'
    }
  end

  let(:school) { create(:school, configuration: { github: github_configuration }) }
  let(:course) { create(:course, school: school) }
  let(:user) { create(:user) }
  let(:student) { create(:student, user: user, course: course) }

  subject { described_class.new(student) }

  before do
    allow_any_instance_of(Schools::Configuration::Github).to receive(:configured?).and_return(true)
  end

  describe '#execute' do
    let(:repository_name) { "student-#{student.id}" }
    let(:repository_full_name) { "#{github_configuration[:organization_id]}/#{repository_name}" }

    context 'when the repository exists' do
      it 'updates the student with the existing repository' do
        allow_any_instance_of(Octokit::Client).to receive(:repository?).with(repository_full_name).and_return(true)
        allow_any_instance_of(Octokit::Client).to receive(:repository).with(repository_full_name).and_return({ full_name: repository_full_name })

        expect { subject.execute }.to change { student.reload.github_repository }.to(repository_full_name)
      end
    end

    context 'when the repository does not exist' do
      it 'creates a new repository and updates the student' do
        allow_any_instance_of(Octokit::Client).to receive(:repository?).with(repository_full_name).and_return(false)
        allow_any_instance_of(Octokit::Client).to receive(:create_repository).and_return({ full_name: repository_full_name })
        allow_any_instance_of(Octokit::Client).to receive(:create_contents).and_return(true)

        expect { subject.execute }.to change { student.reload.github_repository }.to(repository_full_name)
      end
    end

    context 'when adding the workflow starter' do
      it 'creates the README.md file and the workflow file in the repository' do
        allow_any_instance_of(Octokit::Client).to receive(:repository?).with(repository_full_name).and_return(false)
        allow_any_instance_of(Octokit::Client).to receive(:create_repository).and_return({ full_name: repository_full_name })

        expect_any_instance_of(Octokit::Client).to receive(:create_contents).with(
          repository_full_name,
          'README.md',
          'skip ci',
          'workflow_node'
        )

        expect_any_instance_of(Octokit::Client).to receive(:create_contents).with(
          repository_full_name,
          '.github/workflows/ci.js.yml',
          'Add workflow [skip ci]',
          anything
        )

        subject.execute
      end
    end
  end
end
