class BatchDecorator < Draper::Decorator
  delegate_all

  def admission_opening_at
    batch_stages&.find_by(application_stage_id: ApplicationStage.initial_stage)&.starts_at
  end

  def admission_close_at
    batch_stages&.find_by(application_stage_id: ApplicationStage.initial_stage)&.ends_at
  end

  def campaign_days_passed
    return 0 if Time.now < campaign_start_at

    (Date.today - campaign_start_at.to_date).to_i
  end

  def campaign_days_left
    return 0 if Time.now > campaign_start_at

    (admission_close_at.to_date - Date.today).to_i
  end

  def total_campaign_days
    (admission_close_at.to_date - campaign_start_at.to_date).to_i
  end
end
