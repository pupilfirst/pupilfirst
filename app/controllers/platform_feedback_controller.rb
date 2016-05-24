class PlatformFeedbackController < ApplicationController
  def create
    @platform_feedback = PlatformFeedback.new platform_feedback_params

    if @platform_feedback.save!
      flash[:success] = 'Thank You! Your feedback has been sent to the SV.CO team!'
    else
      flash[:error] = 'Something went wrong while saving your feedback! Please try again.'
    end

    redirect_to :back
  end

  private

  def platform_feedback_params
    params.require(:platform_feedback).permit(:founder_id, :feedback_type, :description, :attachment, :promoter_score)
  end
end
