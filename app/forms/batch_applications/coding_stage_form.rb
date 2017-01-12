module BatchApplications
  class CodingStageForm < Reform::Form
    property :git_repo_url, virtual: true, validates: { presence: true, url: true }
    property :app_type, virtual: true
    property :executable, virtual: true, validates: { url: true, allow_blank: true }
    property :website, virtual: true, validates: { url: true, allow_blank: true }

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

    def save
      ApplicationSubmission.transaction do
        model.save!
        model.application_submission_urls.create!(name: 'Code Repository', url: git_repo_url)
        model.application_submission_urls.create!(name: 'Live Website', url: prepend_http_if_required(website)) if website.present?
        model.application_submission_urls.create!(name: 'Application Binary', url: executable) if executable.present?
      end

      IntercomLastApplicantEventUpdateJob.perform_later(model.batch_application.team_lead, 'coding_task_submitted') unless Rails.env.test?
    end

    def prepend_http_if_required(url)
      return url if url.starts_with?('http')
      "http://#{url}"
    end
  end
end
