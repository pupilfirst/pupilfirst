class PlatformFeedbackMailerPreview < ActionMailer::Preview
  def new_platform_feedback
    platform_feedback = PlatformFeedback.last
    PlatformFeedbackMailer.new_platform_feedback(platform_feedback)
  end
end
