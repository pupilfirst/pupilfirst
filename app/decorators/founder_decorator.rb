class FounderDecorator < Draper::Decorator
  delegate_all

  def identification_proof_hint
    hint = "Must be one of #{BatchApplicant::ID_PROOF_TYPES.join ' / '}"

    return hint if identification_proof.blank?

    ("Choose another file if you wish to replace <code>#{filename(:identification_proof)}</code><br/>" + hint).html_safe
  end

  def fb_basic_info
    return nil unless facebook_token_valid?

    @fb_basic_info ||= fb_service.basic_info
  end

  private

  def fb_service
    @fb_service ||= Founders::FacebookService.new(model)
  end
end
