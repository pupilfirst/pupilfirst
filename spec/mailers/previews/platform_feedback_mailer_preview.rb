class PlatformFeedbackMailerPreview < ActionMailer::Preview
  def new_platform_feedback
    platform_feedback = PlatformFeedback.last
    PlatformFeedbackMailer.new_platform_feedback(platform_feedback)
  end

  def acknowledgement
    platform_feedback = PlatformFeedback.last
    PlatformFeedbackMailer.acknowledgement(platform_feedback)
  end
end
