class PlatformFeedbackController < ApplicationController
  def create
    @platform_feedback = authorize(PlatformFeedback.new(platform_feedback_params))

    if @platform_feedback.save!
      # Mail help@sv.co about the submission.
      PlatformFeedbackMailer.new_platform_feedback(@platform_feedback).deliver_later

      # Mail an acknowledgement to the founder.
      PlatformFeedbackMailer.acknowledgement(@platform_feedback).deliver_later

      flash[:success] = 'Thank You! Your feedback has been sent to the SV.CO team!'
    else
      flash[:error] = 'Something went wrong while saving your feedback! Please try again.'
    end

    redirect_back(fallback_location: root_url)
  end

  private

  def platform_feedback_params
    params.require(:platform_feedback).permit(:founder_id, :feedback_type, :description, :promoter_score)
  end
end
