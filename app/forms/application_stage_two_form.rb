class ApplicationStageTwoForm < Reform::Form
  property :git_repo_url, virtual: true, validates: { presence: true, url: true }
  property :video_url, virtual: true, validates: { presence: true, url: true }

  # Ensure git_repo_url is from github or bitbucket
  validate :git_repo_url_must_be_acceptable

  def git_repo_url_must_be_acceptable
    errors[:git_repo_url] = 'is not a valid Github or Bitbucket url' unless git_repo_url =~ %r{https?\://.*(github|bitbucket)}
  end

  # Ensure video_url is from youtube or vimeo
  validate :video_url_must_be_acceptable

  def video_url_must_be_acceptable
    errors[:video_url] = 'is not a valid Youtube or Vimeo url' unless video_url =~ %r{https?\://.*(youtube|vimeo)}
  end

  def save
    ApplicationSubmission.transaction do
      # Create the application submission.
      model.save!

      # Add 2 submission urls to the submission.
      model.application_submission_urls.create!(name: 'Code Submission', url: git_repo_url)
      model.application_submission_urls.create!(name: 'Video Submission', url: video_url)
    end
  end
end
