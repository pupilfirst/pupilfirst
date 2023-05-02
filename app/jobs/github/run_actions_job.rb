module Github
  class RunActionsJob < ApplicationJob
    queue_as :default

    def perform(submission, re_run: false)
      Github::AddSubmissionService.new(submission).execute(re_run: re_run)
    end
  end
end
