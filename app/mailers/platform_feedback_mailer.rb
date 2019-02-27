# Mails sent as a reaction to platform feedback.
class PlatformFeedbackMailer < SchoolMailer
  def new_platform_feedback(platform_feedback)
    @platform_feedback = platform_feedback
    @school = platform_feedback.founder.school

    roadie_mail(
      {
        to: 'help@sv.co',
        subject: "Plaftorm Feedback (#{@platform_feedback.feedback_type}) by #{@platform_feedback.founder.fullname}",
        **from_options
      },
      roadie_options_for_school
    )
  end

  def acknowledgement(platform_feedback)
    @platform_feedback = platform_feedback
    @founder = platform_feedback.founder
    @school = @founder.school

    roadie_mail(
      {
        to: platform_feedback.founder.email,
        subject: 'Thank you for submitting feedback to SV.CO',
        **from_options
      },
      roadie_options_for_school
    )
  end
end
