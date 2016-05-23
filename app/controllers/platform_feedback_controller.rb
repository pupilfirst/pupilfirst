class PlatformFeedbackController < ApplicationController
  def create
    @platform_feedback = PlatformFeedback.new platform_feedback_params

    if @platform_feedback.save!
      flash[:success] = 'Thank You! Your feedback has been sent to the SV.CO team!'
      redirect_to :back
    else
      flash[:error] = 'Something went wrong while saving your feedback! Please try again.'
      redirect_to :back
    end
  end

  private

  def platform_feedback_params
    params.require(:platform_feedback).permit(:founder_id, :feedback_type, :description, :attachment, :promoter_score)
  end
end
