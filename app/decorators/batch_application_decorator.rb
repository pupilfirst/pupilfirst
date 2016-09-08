class BatchApplicationDecorator < Draper::Decorator
  delegate_all

  def certificate_background_image_base64
    APP_CONSTANTS[:certificate_background_base64]
  end

  def team_member_names
    batch_applicants.pluck(:name).sort
  end

  # Returns the score given for the code submission
  def coding_task_score
    score_from_database = ApplicationSubmissionUrl.joins(:application_submission).where(
      application_submissions: { batch_application_id: id }
    ).find_by(name: 'Code Submission')&.score

    score_from_database || 'Not Available'
  end

  # Returns the score given for the video submission
  def video_task_score
    score_from_database = ApplicationSubmissionUrl.joins(:application_submission).where(
      application_submissions: { batch_application_id: id }
    ).find_by(name: 'Video Submission')&.score

    score_from_database || 'Not Available'
  end

  def preliminary_result
    application_stage.number > 2 ? 'Selected' : 'Not Selected'
  end
end
