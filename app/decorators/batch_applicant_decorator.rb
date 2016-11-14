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
end
