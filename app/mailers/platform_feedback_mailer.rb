class PlatformFeedbackMailer < ApplicationMailer
  def new_platform_feedback(platform_feedback)
    @platform_feedback = platform_feedback

    mail(
      to: 'help@sv.co',
      subject: "Plaftorm Feedback (#{@platform_feedback.feedback_type}) by #{@platform_feedback.founder.fullname}",
      reply_to: @platform_feedback.founder.email
    )
  end
end
