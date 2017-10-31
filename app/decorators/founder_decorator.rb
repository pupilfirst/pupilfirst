class FounderDecorator < Draper::Decorator
  delegate_all

  def identification_proof_hint
    hint = "Must be one of #{Founder::ID_PROOF_TYPES.join ' / '}"

    return hint if identification_proof.blank?

    ("Choose another file if you wish to replace <code>#{filename(:identification_proof)}</code><br/>" + hint).html_safe
  end

  def college_identification_hint
    return if college_identification.blank?
    "Choose another file if you wish to replace <code>#{filename(:college_identification)}</code><br/>".html_safe
  end

  def avatar_hint
    return if avatar.blank?
    'Choose another file if you wish to replace your current avatar.'
  end

  def fb_basic_info
    return nil unless facebook_token_valid?

    @fb_basic_info ||= fb_service.basic_info
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

  def mr_or_ms
    if gender == Founder::GENDER_MALE
      'Mr'
    elsif gender == Founder::GENDER_FEMALE
      'Ms'
    else
      'Mr/Ms'
    end
  end

  private

  def fb_service
    @fb_service ||= Founders::FacebookService.new(model)
  end
end
