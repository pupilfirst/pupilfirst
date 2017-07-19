class FounderDecorator < Draper::Decorator
  delegate_all

  def identification_proof_hint
    hint = "Must be one of #{Founder::ID_PROOF_TYPES.join ' / '}"

    return hint if identification_proof.blank?

    ("Choose another file if you wish to replace <code>#{filename(:identification_proof)}</code><br/>" + hint).html_safe
  end

  def fb_basic_info
    return nil unless facebook_token_valid?

    @fb_basic_info ||= fb_service.basic_info
  end

  def form
    @form ||= Founders::EditForm.new(model)
  end

  def age
    return nil if born_on.blank?
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
      when 'Hardship Scholarship'
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
    update_query = "?update_profile=#{id}#update_founder_form"

    if profile_complete?
      "<div class='tag tag-pill tag-primary m-r-1'><i class='fa fa-check-circle'></i>&nbsp;Complete</div><span class='text-nowrap'>#{h.link_to('<i class="fa fa-edit"></i> Edit'.html_safe, update_query, class: 'edit-btn')}</span>".html_safe
    else
      h.link_to('<i class="fa fa-list-alt"></i> Update profile'.html_safe, update_query)
    end
  end

  def payment_method_with_fee(startup)
    return 'Not Available' if fee_payment_method.blank?

    if fee_payment_method == Founder::PAYMENT_METHOD_REGULAR_FEE
      fee = startup.founder_course_fee(model)
      "Regular Fee &ndash; <strong>&#8377;#{h.number_with_delimiter(fee)}</strong>".html_safe
    else
      fee_payment_method
    end
  end

  private

  def fb_service
    @fb_service ||= Founders::FacebookService.new(model)
  end
end
