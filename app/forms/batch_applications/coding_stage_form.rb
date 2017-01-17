module BatchApplications
  class CodingStageForm < Reform::Form
    SUBMISSION_TYPES = %w(coding_task previous_work).freeze

    property :submission_type, validates: { inclusion: SUBMISSION_TYPES }
    property :git_repo_url, validates: { presence: true, url: true }
    property :app_type
    property :executable, validates: { url: true, allow_blank: true }
    property :website, validates: { url: true, allow_blank: true }

    # Ensure git_repo_url is from github or bitbucket
    validate :git_repo_url_must_be_acceptable
    validate :executable_or_website_must_be_supplied

    def git_repo_url_must_be_acceptable
      errors[:git_repo_url] << 'is not a valid Github or Bitbucket URL' unless git_repo_url =~ %r{https?\://.*(github|bitbucket)}
    end

    def executable_or_website_must_be_supplied
      return if executable.present? || website.present?
      errors[:base] << 'Either one of website or executable must be supplied.'
      errors[:executable] << 'either this or website should be supplied'
      errors[:website] << 'either this or executable should be supplied'
    end

    def save(batch_application)
      ApplicationSubmission.transaction do
        notes = if submission_type == 'coding_task'
          # Since submission is a coding task, the application merits a certificate.
          batch_application.update!(generate_certificate: true)
          'Coding Task Submission'
        else
          # Since submissions is previous work, we won't be comparing it against other submissions.
          batch_application.update!(generate_certificate: false)
          'Previous Work Submission'
        end

        submission = ApplicationSubmission.create!(
          application_stage: ApplicationStage.find_by(number: 3),
          batch_application: batch_application,
          notes: notes
        )

        submission.application_submission_urls.create!(name: 'Code Repository', url: git_repo_url)
        submission.application_submission_urls.create!(name: 'Live Website', url: prepend_http_if_required(website)) if website.present?
        submission.application_submission_urls.create!(name: 'Application Binary', url: prepend_http_if_required(executable)) if executable.present?
      end

      IntercomLastApplicantEventUpdateJob.perform_later(batch_application.team_lead, 'coding_task_submitted') unless Rails.env.test?
    end

    def prepend_http_if_required(url)
      return url if url.starts_with?('http')
      "http://#{url}"
    end
  end
end
