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
    update_query = "?update_profile=#{id}#update_applicant_form"

    if profile_complete?
      "<div class='tag tag-pill tag-primary m-r-1'><i class='fa fa-check-circle'></i>&nbsp;Complete</div><span class='text-nowrap'>#{h.link_to('<i class="fa fa-edit"></i> Edit'.html_safe, update_query, class: 'edit-btn')}</span>".html_safe
    else
      h.link_to('<i class="fa fa-list-alt"></i> Update profile'.html_safe, update_query)
    end
  end

  def payment_method_with_fee(batch_application)
    return 'Not Available' if fee_payment_method.blank?

    if fee_payment_method == BatchApplicant::PAYMENT_METHOD_REGULAR_FEE
      fee = batch_application.applicant_course_fee(model)
      "Regular Fee &ndash; <strong>&#8377;#{h.number_with_delimiter(fee)}</strong>".html_safe
    else
      fee_payment_method
    end
  end
end
