class BatchApplicantDecorator < Draper::Decorator
  delegate_all

  def college_name
    college&.name || college_text
  end

  def university_name
    college&.replacement_university&.name
  end

  def batch_name
    batch_applications&.last&.batch&.name
  end

  # TODO: Update the following to account for events after task submissions
  def last_applicant_event
    return nil unless batch_applications.any?

    latest_application = batch_applications.last

    return 'tasks_submitted' if latest_application.application_submissions.where(application_stage: ApplicationStage.find_by(name: 'Testing')).any?

    return 'payment_complete' if latest_application.paid?

    return 'payment_initiated' if latest_application.payment.present?

    'submitted_application'
  end

  def age
    return nil unless born_on.present?
    Date.today.year - born_on.year
  end

  def son_or_daughter
    if gender == Founder::GENDER_MALE
      'son'
    elsif gender == Founder::GENDER_FEMALE
      'daughter'
    else
      'son/daughter'
    end
  end

  def confirmation_status
    case fee_payment_method
      when 'Regular Fee', 'Merit Scholarship'
        'Confirmed'
      when 'Postpaid Fee', 'Hardship Scholarship'
        'Valid on Submission of Documents'
      else
        'Not Available'
    end
  end

  def mr_or_ms
    if gender == Founder::GENDER_MALE
      'Mr'
    elsif gender == Founder::GENDER_FEMALE
      'Ms'
    else
      'Mr/Ms'
    end
  end

  def profile_completion_status
    profile_complete? ? 'Complete' : h.link_to('<i class="fa fa-edit"></i> Update profile'.html_safe, "?update_profile=#{id}#update_applicant_form")
  end
end
