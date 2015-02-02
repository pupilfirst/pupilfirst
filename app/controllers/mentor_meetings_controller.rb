class MentorMeetingsController < ApplicationController
  before_filter :authenticate_user!
  before_filter :meeting_started, only: [:feedback]
  before_filter :meeting_completed, only: [:feedbacksave]
  
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

  # TODO: Refactor fat MentorMeetingsController#create
  def create
    raise_not_found unless current_user.startup.present?
  	mentor = Mentor.find params[:mentor_id]
  	@mentor_meeting = mentor.mentor_meetings.new(meeting_params)
  	@mentor_meeting.user = current_user
  	if @mentor_meeting.save
  		UserMailer.meeting_request_to_mentor(@mentor_meeting).deliver
      flash[:notice]="Meeting request sent"
  		redirect_to mentoring_path(current_user)
  	else
  		flash[:alert]="Failed to create new meeting request"
  		render 'new'
  	end
  end

  def index
  	@mentor_meetings = MentorMeeting.all
  end

  # POST /mentor_meetings/:id/accept
  def accept
    mentor_meeting = MentorMeeting.find(params[:id])
    mentor_meeting.accept!(params[:mentor_meeting][:meeting_at])

    flash[:notice] = 'Startup member will be notified of your acceptance.'

    redirect_to mentoring_url
  end

  # POST /mentor_meetings/:id/reject
  def reject
    mentor_meeting = MentorMeeting.find(params[:id])
    mentor_meeting.reject!(params[:mentor_meeting][:mentor_comments])

    flash[:notice] = 'Startup member will be notified of your response.'

    redirect_to mentoring_url
  end

  # POST /mentor_meetings/:id/start
  def start
    mentor_meeting = MentorMeeting.find(params[:id])
    mentor_meeting.start!
    render nothing: true
  end

  def feedback
    @mentor_meeting = MentorMeeting.find(params[:id])
    @role = role(@mentor_meeting)
    flash.now[:notice] = "Your meeting with #{guest(@mentor_meeting).fullname} has ended"
    @mentor_meeting.complete!
  end

  def feedbacksave
    @mentor_meeting = MentorMeeting.find(params[:id])

    if @mentor_meeting.update(feedback_params)
      flash[:notice] = 'Thank you for your feedback!'
      redirect_to mentoring_path
    else
      flash[:error] = 'Could not save your feedback. Please try again.'
      render 'feedback'
    end
  end

  def reminder
    @mentor_meeting = MentorMeeting.find(params[:id])
    @mentor_meeting.sent_sms(current_user)
    head :ok
  end

  private

  def meeting_params
    params.require(:mentor_meeting).permit(:purpose,:suggested_meeting_at,:suggested_meeting_time,:duration)
  end

  def feedback_params
    params.require(:mentor_meeting).permit(:user_rating,:mentor_rating,:user_comments,:mentor_comments)
  end

  def meeting_started
    raise_not_found if !(MentorMeeting.find(params[:id]).status == MentorMeeting::STATUS_STARTED || MentorMeeting.find(params[:id]).status == MentorMeeting::STATUS_COMPLETED)
  end

  def meeting_completed
    raise_not_found if MentorMeeting.find(params[:id]).status != MentorMeeting::STATUS_COMPLETED
  end

  def role(mentormeeting)
    current_user == mentormeeting.user ? "user" : "mentor"
  end

  def guest(mentormeeting)
    current_user == mentormeeting.user ? mentormeeting.mentor.user : mentormeeting.user
  end

end
