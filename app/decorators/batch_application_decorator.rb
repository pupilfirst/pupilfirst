class BatchApplicationDecorator < Draper::Decorator
  delegate_all

  def certificate_background_image_base64
    APP_CONSTANTS[:certificate_background_base64]
  end

  def team_member_names
    batch_applicants.pluck(:name).sort
  end

  def preliminary_result
    application_stage.number > 2 ? 'Selected for Interview' : 'Not Selected'
  end

  def percentile_code_score
    grade[:code]&.round(1) || 'Not Available'
  end

  def percentile_video_score
    grade[:video]&.round(1) || 'Not Available'
  end

  def overall_percentile
    @overall_percentile ||= grading_service.overall_percentile&.round(1)
  end

  # used in stage4.html.slim
  def batch_start_date
    batch.start_date.strftime('%B %d, %Y')
  end

  # used to display submission deadline in stage4.html.slim
  def document_submission_deadline
    batch.batch_stages.where(application_stage: ApplicationStage.shortlist_stage).first.ends_at.strftime('%B %d, %Y')
  end

  # used to display interview feedback in stage_3_rejected.html.slim
  def interview_feedback
    application_submissions.where(application_stage: ApplicationStage.interview_stage).last&.feedback_for_team
  end

  def founders_profiles_complete?
    batch_applicants.all?(&:profile_complete?)
  end

  alias partnership_deed_ready? founders_profiles_complete?
  alias incubation_agreement_ready? founders_profiles_complete?

  private

  def grading_service
    BatchApplicationGradingService.new(model)
  end

  def grade
    @grade ||= grading_service.grade
  end
end
