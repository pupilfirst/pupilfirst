class PlatformFeedbackMailerPreview < ActionMailer::Preview
  def new_platform_feedback
    PlatformFeedbackMailer.new_platform_feedback(platform_feedback)
  end

  def acknowledgement
    PlatformFeedbackMailer.acknowledgement(platform_feedback)
  end

  private

  def platform_feedback
    PlatformFeedback.new(
      founder: Founder.last,
      feedback_type: PlatformFeedback.types_of_feedback.sample,
      description: Faker::Lorem.paragraphs(number: 2).join("\n\n")
    )
  end
end
