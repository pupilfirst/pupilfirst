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

  def batch_start_date
    batch.start_date.strftime('%B %d, %Y')
  end

  def batch_number
    batch.batch_number
  end

  def document_submission_deadline
    (batch.start_date - 15.days).strftime('%B %d, %Y')
  end

  def fee_payment_table
    batch_applicants.each_with_object([]) do |applicant, result|
      result << {
        name: applicant.name,
        method: applicant.fee_payment_method.presence || 'Not Available',
        confirmation: confirmation_status(applicant)
      }
    end
  end

  private

  def grading_service
    BatchApplicationGradingService.new(model)
  end

  def grade
    @grade ||= grading_service.grade
  end

  def confirmation_status(applicant)
    case applicant.fee_payment_method
      when 'Regular Fee', 'Merit Scholarship'
        'Confirmed'
      when 'Postpaid Fee', 'Hardship Scholarship'
        'Valid on Submission of Documents'
      else
        'Not Available'
    end
  end
end
