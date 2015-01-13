class MentorMeetingsController < ApplicationController
  
  def live
    @mentor_meeting = MentorMeeting.find(params[:id])
  end

  def new
    if current_user.startup.agreement_live?
  	 mentor = Mentor.find params[:mentor_id]
  	 @mentor_meeting = mentor.mentor_meetings.new
    else 
      flash[:alert]="Please sign/renew your agreement with SV to meet our mentors!"
      redirect_to mentoring_url
    end
  end

  def create
    raise_not_found unless current_user.startup.present?
  	mentor = Mentor.find params[:mentor_id]
  	@mentor_meeting = mentor.mentor_meetings.new(meeting_params)
  	@mentor_meeting.user = current_user
  	if @mentor_meeting.save
  		UserMailer.meeting_request_to_mentor(@mentor_meeting).deliver
  		redirect_to mentoring_path(current_user)
  	else
  		flash[:alert]="Failed to create new meeting request"
  		render 'new'
  	end
  end

  def index
  	@mentor_meetings = MentorMeeting.all
  end

  def update
    @mentor_meeting = current_user.mentor.mentor_meetings.find(params[:id])
    @mentor_meeting.status = params[:commit] == "Accept" ? MentorMeeting::STATUS_ACCEPTED : MentorMeeting::STATUS_REJECTED
    @mentor_meeting.meeting_at = @mentor_meeting.suggested_meeting_at if params[:commit] == "Accept"   
    if @mentor_meeting.save
      flash[:notice] = "Meeting status has been updated"
      UserMailer.meeting_request_accepted(@mentor_meeting).deliver if @mentor_meeting.status == MentorMeeting::STATUS_ACCEPTED
      UserMailer.meeting_request_rejected(@mentor_meeting).deliver if @mentor_meeting.status == MentorMeeting::STATUS_REJECTED
    else 
      flash[:alert] = "Error in saving response"
    end
    redirect_to mentoring_url 
  end

  def feedback
    @mentor_meeting = MentorMeeting.find(params[:id])
    @mentor_meeting.status = MentorMeeting::STATUS_AWAITFB
    @mentor_meeting.save
    @role = current_user == @mentor_meeting.user ? "user" : "mentor"
    flash[:notice] = "Your meeting with #{current_user == @mentor_meeting.user ? @mentor_meeting.mentor.user.fullname : @mentor_meeting.user.fullname} has ended"
  end

  def feedbacksave
    @mentor_meeting = MentorMeeting.find(params[:id])
    if @mentor_meeting.status == MentorMeeting::STATUS_AWAITFB
      if params[:commit] == "Later"
        flash[:notice] = "Check your inbox for feedback remainders"
        # if current_user == @mentor_meeting.user
        #   UserMailer.meeting_feedback_user(@mentor_meeting).deliver
        # elsif current_user == @mentor_meeting.mentor.user
        #   UserMailer.meeting_feedback_mentor(@mentor_meeting).deliver
        # end
        redirect_to mentoring_path
      else
        if @mentor_meeting.update(feedback_params)
          @mentor_meeting.status == MentorMeeting::STATUS_COMPLETED
          flash[:notice] = "Thank you for your feedback!"
          redirect_to mentoring_path
        else
          flash[:error] = "Could not save your feedback. Try again"
          render 'feedback'
        end
      end
    else
      flash[:notice] = "This meeting is not yet complete"
      redirect_to mentoring_path
    end
  end


  private
  	def meeting_params
  		params.require(:mentor_meeting).permit(:purpose,:suggested_meeting_at,:suggested_meeting_time,:duration)
  	end

    def feedback_params
      params.require(:mentor_meeting).permit(:user_rating,:mentor_rating,:user_comments,:mentor_comments)
    end

end
