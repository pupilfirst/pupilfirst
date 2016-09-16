class BatchApplicationDecorator < Draper::Decorator
  delegate_all

  def certificate_background_image_base64
    APP_CONSTANTS[:certificate_background_base64]
  end

  def team_member_names
    batch_applicants.pluck(:name).sort
  end

  def preliminary_result
    application_stage.number > 2 ? 'Selected' : 'Not Selected'
  end

  def percentile_code_score
    grade[:code] || 'Not Available'
  end

  def percentile_video_score
    grade[:video] || 'Not Available'
  end

  private

  def grade
    @grade ||= BatchApplicationGradingService.grade(model)
  end
end
