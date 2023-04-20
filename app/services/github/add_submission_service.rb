module Github
  class AddSubmissionService
    def initialize(submission)
      @submission = submission
    end

    def execute(re_run: false)
      unless github_configuration.configured? &&
               submission.target.action_config.present?
        return
      end

      repository = find_or_create_repository
      branch = create_branch(repository)
      add_contents(branch, repository)
    end

    private

    def find_or_create_repository
      organization = github_configuration.organization_id
      repository_name = "student-#{@submission.founders.first.id}"
      repository =
        github_client.repository(organization + '/' + repository_name)

      if repository.id.blank?
        # Create a new repository with the name student-<student_id>
        github_client.create_repository(
          repository_name,
          organization: organization,
          private: 'true',
          team_id: team_id,
          description:
            "Submissions from #{@submission.founders.first.user.name}"
        )

        # Create the main branch for the repository and add the workflow starter file
        add_workflow_starter("#{organization}/#{repository_name}")
      end

      repository_name
    end

    def create_branch(repo)
      # Create a branch with the name submission-<student_id>
      branch_name = "submission-#{@submission.id}"

      # Create the respository name with the organization name
      repo_name = "#{github_configuration.organization_id}/#{repo}"

      # Get the sha of the last commit on the main branch
      latest_sha = get_main_branch_sha(repo_name)

      # Create the branch with the last commit sha of the main branch as the base
      github_client.create_ref repo_name, "heads/#{branch_name}", latest_sha

      branch_name
    end

    def get_main_branch_sha(repo_name)
      commits_from_main_branch = github_client.commits(repo_name, 'heads/main')

      if commits_from_main_branch.class == Array
        # Get Sha of last commit
        commits_from_main_branch.first&.sha
      else
        # Create the main branch and get the Sha of the last commit
        last_commit = add_workflow_starter(repo_name)
        last_commit.content.sha
      end
    end

    def add_workflow_starter(repo_name)
      # Add Readme file to the repo
      github_client.create_contents(
        repo_name,
        'README.md',
        'skip ci',
        'workflow_node'
      )

      # Add a workflow starter file to the repo to trigger the GA workflow for the first time
      # This is needed because the GA workflow will not run on first push of a workflow file
      github_client.create_contents(
        repo_name,
        '.github/workflows/ci.js.yml',
        'Add workflow [skip ci]',
        starter_workflow_content
      )
    end

    def add_contents(branch, repo)
      repo_name = "#{github_configuration.organization_id}/#{repo}"
      github_client.update_contents(
        repo_name,
        '.github/workflows/ci.js.yml',
        'Update workflow [skip ci]',
        ci_file(repo_name).sha,
        @submission.target.action_config,
        branch: branch
      )
      add_submission_file(branch, repo_name)
      github_client.create_contents(
        repo_name,
        'submission.json',
        'Add submission data',
        submission_data_service.data.to_json,
        branch: branch
      )
    end

    def github_client
      @github_client ||=
        Octokit::Client.new(access_token: github_configuration.access_token)
    end

    def add_submission_file(branch, repo)
      return if submission_data_service.files.empty?

      file = submission_data_service.files.first

      begin
        uri = URI.parse(file['url'])
        file_content = Net::HTTP.get(uri)
      rescue StandardError
        raise 'Unable to read file or source file missing'
      else
        github_client.create_contents(
          repo,
          'script' + File.extname(file['filename']),
          'Add submission file[skip ci]',
          file_content,
          branch: branch
        )
      end
    end

    def github_configuration
      @github_configuration ||=
        Schools::Configuration::Github.new(@submission.school)
    end

    def submission_data_service
      @submission_data_service ||=
        TimelineEvents::CreateWebhookDataService.new(@submission)
    end

    def team_id
      @team_id ||=
        @submission.course.github_team_id.presence ||
          github_configuration.default_team_id
    end

    def ci_file(repo_name)
      begin
        github_client.contents(repo_name, path: '.github/workflows/ci.js.yml')
      rescue StandardError
        Rails.logger.error 'Error while fetching the ci.js.yml file'
      end
    end

    def starter_workflow_content
      <<-DOC
name: Node.js Test Runner
on:
  push:
    branches: [ "submission-*" ]
jobs:
  build:
    runs-on: ubuntu-latest
    strategy:
      matrix:
        node-version: [ 14.x ]
    steps:
      - run: |
          echo "Let the tests begin"
      DOC
    end
  end
end
