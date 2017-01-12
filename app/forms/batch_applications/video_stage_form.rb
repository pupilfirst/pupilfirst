module BatchApplications
  class CodingStageForm < Reform::Form
    property :video_url, virtual: true, validates: { presence: true, url: true }

    validate :coapplicants_should_be_present
    validate :video_url_must_be_acceptable

    def coapplicants_should_be_present
      application = model.batch_application
      return if application.cofounders.count.positive?
      errors[:base] << 'Please add cofounders before submitting this form.'
    end

    # Ensure video_url is from YouTube or Vimeo.
    def video_url_must_be_acceptable
      errors[:video_url] << 'is not a valid Facebook URL' unless video_url =~ %r{https?\://.*(facebook)}
    end

    def save
      ApplicationSubmission.transaction do
        model.save!
        model.application_submission_urls.create!(name: 'Video Submission', url: video_url)
      end

      IntercomLastApplicantEventUpdateJob.perform_later(model.batch_application.team_lead, 'video_task_submitted') unless Rails.env.test?
    end
  end
end
