class BatchApplicationGradingService
  attr_reader :batch_application

  def initialize(batch_application)
    @batch_application = batch_application
  end

  def grade
    {
      code: code_percentile,
      video: video_percentile
    }
  end

  def overall_percentile
    return unless total_submissions.positive? && submission_score.present?

    (defeated_submissions.to_f / total_submissions) * 100
  end

  private

  def code_percentile
    return unless total_submissions.positive? && code_score.present?

    (defeated_code_submissions.to_f / total_submissions) * 100
  end

  def video_percentile
    return unless total_submissions.positive? && video_score.present?

    (defeated_video_submissions.to_f / total_submissions) * 100
  end

  def submission_score
    @submission ||= batch_application.application_submissions.find_by(
      application_stage: ApplicationStage.testing_stage
    )&.score
  end

  def code_score
    @code_score ||= ApplicationSubmissionUrl.joins(:application_submission).where(
      application_submissions: { batch_application_id: batch_application.id }
    ).find_by(name: 'Code Submission')&.score
  end

  def video_score
    @video_score ||= ApplicationSubmissionUrl.joins(:application_submission).where(
      application_submissions: { batch_application_id: batch_application.id }
    ).find_by(name: 'Video Submission')&.score
  end

  def total_submissions
    @total_submissions ||= ApplicationSubmission.joins(:batch_application)
      .where(batch_applications: { batch_id: batch_application.batch.id })
      .where(application_stage: ApplicationStage.testing_stage)
      .count
  end

  def defeated_submissions
    @defeated_submissions ||= begin
      ApplicationSubmission.joins(:batch_application)
        .where(batch_applications: { batch_id: batch_application.batch.id })
        .where(application_stage: ApplicationStage.testing_stage)
        .where('score < ?', submission_score)
        .count
    end
  end

  def defeated_code_submissions
    ApplicationSubmissionUrl.joins(application_submission: :batch_application)
      .where(batch_applications: { batch_id: batch_application.batch.id }, name: 'Code Submission')
      .where('application_submission_urls.score < ?', code_score)
      .count
  end

  def defeated_video_submissions
    ApplicationSubmissionUrl.joins(application_submission: :batch_application)
      .where(batch_applications: { batch_id: batch_application.batch.id }, name: 'Video Submission')
      .where('application_submission_urls.score < ?', video_score)
      .count
  end
end
