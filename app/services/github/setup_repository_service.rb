module Github
  class SetupRepositoryService
    def initialize(student)
      @student = student
    end

    def execute
      unless github_configuration.configured? &&
               @student.github_repository.blank?
        return
      end

      repository_name = "student-#{@student.id}"
      repository_full_name = "#{github_configuration.organization_id}/#{repository_name}"

      if github_client.repository?(repository_full_name)
        @student.update!(github_repository: repository_full_name)
      else
        # Create a new repository with the name student-<student_id>
        github_client.create_repository(
          repository_name,
          organization: github_configuration.organization_id,
          private: 'true',
          team_id: team_id,
          description: "Submissions from #{@student.user.name}"
        )

        # Create the main branch for the repository and add the workflow starter file
        add_workflow_starter(repository_full_name)

        @student.update!(github_repository: repository_full_name)
      end

      repository_full_name
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

    private

    def github_client
      @github_client ||=
        Octokit::Client.new(access_token: github_configuration.access_token)
    end

    def github_configuration
      @github_configuration ||=
        Schools::Configuration::Github.new(@student.course.school)
    end

    def team_id
      @team_id ||=
        @student.course.github_team_id.presence ||
          github_configuration.default_team_id
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
