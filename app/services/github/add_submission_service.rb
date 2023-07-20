module Github
  class AddSubmissionService
    def initialize(submission)
      @submission = submission
    end

    def execute(re_run: false)
      unless github_configuration.configured? &&
               @submission.target.action_config.present?
        return
      end

      if @submission.students.first.github_repository.blank?
        Github::SetupRepositoryService.new(@submission.students.first).execute
        @submission
          .submission_reports
          .find_or_create_by!(
            reporter: SubmissionReport::VIRTUAL_TEACHING_ASSISTANT,
          )
          .update!(target_url: @submission.actions_url)
      end

      branch = create_branch(re_run)
      repo_name = @submission.students.first.github_repository

      # Add the workflow file
      github_client.update_contents(
        repo_name,
        ".github/workflows/ci.js.yml",
        "Update workflow [skip ci]",
        ci_file_sha(repo_name),
        @submission.target.action_config,
        branch: branch,
      )

      # Add files to the repo
      add_submission_file(branch, repo_name)

      # Dump the submission data to a file
      github_client.create_contents(
        repo_name,
        "submission.json",
        "Add submission data",
        submission_data_service.data.to_json,
        branch: branch,
      )
    end

    private

    def create_branch(re_run)
      # Create a branch with the name submission-<student_id>
      branch_name = "submission-#{@submission.id}"

      branch_name = "#{branch_name}-#{Time.now.to_i}" if re_run

      repo_name = @submission.students.first.github_repository

      # Get the sha of the last commit on the main branch
      latest_sha = get_main_branch_sha(repo_name)

      # Create the branch with the last commit sha of the main branch as the base
      github_client.create_ref repo_name, "heads/#{branch_name}", latest_sha

      branch_name
    end

    def get_main_branch_sha(repo_name)
      commits_from_main_branch = github_client.commits(repo_name, "heads/main")

      if commits_from_main_branch.class == Array
        # Get Sha of last commit
        commits_from_main_branch.first&.sha
      else
        # Create the main branch and get the Sha of the last commit
        last_commit =
          Github::SetupRepositoryService.new(
            @submission.students.first,
          ).add_workflow_starter(repo_name)
        last_commit.content.sha
      end
    end

    def add_submission_file(branch, repo)
      return if submission_data_service.files.empty?

      file = submission_data_service.files.first

      begin
        uri = URI.parse(file[:url])
        file_content = Net::HTTP.get(uri)
      rescue StandardError
        raise "Unable to read file or source file missing"
      else
        github_client.create_contents(
          repo,
          "script" + File.extname(file[:filename]),
          "Add submission file[skip ci]",
          file_content,
          branch: branch,
        )
      end
    end

    def ci_file_sha(repo_name)
      begin
        github_client.contents(
          repo_name,
          path: ".github/workflows/ci.js.yml",
        ).sha
      rescue StandardError
        Rails.logger.error "Error while fetching the ci.js.yml file"
      end
    end

    def github_configuration
      @github_configuration ||=
        Schools::Configuration::Github.new(@submission.course.school)
    end

    def submission_data_service
      @submission_data_service ||=
        TimelineEvents::CreateWebhookDataService.new(@submission)
    end

    def github_client
      @github_client ||=
        Octokit::Client.new(access_token: github_configuration.access_token)
    end
  end
end
