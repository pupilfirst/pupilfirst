# Mails sent as a reaction to platform feedback.
class PlatformFeedbackMailer < SchoolMailer
  def new_platform_feedback(platform_feedback)
    @platform_feedback = platform_feedback
    @school = platform_feedback.founder.school

    roadie_mail(
      from: from,
      to: 'help@sv.co',
      subject: "Plaftorm Feedback (#{@platform_feedback.feedback_type}) by #{@platform_feedback.founder.fullname}"
    )
  end

  def acknowledgement(platform_feedback)
    @platform_feedback = platform_feedback
    @founder = platform_feedback.founder
    @school = @founder.school

    roadie_mail(from: from, to: platform_feedback.founder.email, subject: 'Thank you for submitting feedback to SV.CO')
  end
end
