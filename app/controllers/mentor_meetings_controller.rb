class MentorMeetingsController < ApplicationController
  before_filter :authenticate_user!
  before_filter :meeting_completed, only: [:feedbacksave]
  before_filter :meeting_room_accessible, only: [:live]
  before_filter :accept_reject_rights, only: [:accept, :reject]
  before_filter :meeting_member, except: [:new, :create, :index]

  def live
    @mentor_meeting = MentorMeeting.find(params[:id])
  end

  def new
    if current_user.startup.agreement_live?
  	   mentor = Mentor.find params[:mentor_id]
      if MentorMeeting.scheduled_to_meet?(current_user,mentor)
        flash[:alert]="You already have a pending meeting with this mentor"
        redirect_to mentoring_url
      else
  	   @mentor_meeting = mentor.mentor_meetings.new
     end
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
  		MentoringMailer.meeting_request_to_mentor(@mentor_meeting).deliver
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
    mentor_meeting.accept!(params[:mentor_meeting],current_user)
    flash[:notice] = "#{guest(mentor_meeting).fullname} will be notified of your acceptance."
    redirect_to mentoring_url
  end

  # POST /mentor_meetings/:id/reject
  def reject
    binding.pry
    mentor_meeting = MentorMeeting.find(params[:id])
    mentor_meeting.reject!(params[:mentor_meeting],current_user)
    flash[:notice] = "#{guest(mentor_meeting).fullname}  will be notified of your response."
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
    raise_not_found unless @mentor_meeting.started? || @mentor_meeting.completed?
    flash.now[:notice] = "Your meeting with #{guest(@mentor_meeting).fullname} has been completed"
    @mentor_meeting.complete!
    if @mentor_meeting.founder?(current_user)
      render 'feedback_for_user'
    else render 'feedback_for_mentor'
    end
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

  def reschedule
    @mentor_meeting = MentorMeeting.find(params[:id])
    raise_not_found unless @mentor_meeting.mentor?(current_user) && @mentor_meeting.requested?
    new_time = params[:mentor_meeting][:suggested_meeting_at]
    if @mentor_meeting.to_be_rescheduled?(new_time)
      @mentor_meeting.reschedule!(new_time)
      flash[:notice] = 'The revised schedule has been sent to the startup for confirmation'
      redirect_to mentoring_path
    else
      accept
    end
  end

  def cancel
    binding.pry
    mentor_meeting = MentorMeeting.find(params[:id])
    mentor_meeting.cancel!(params[:mentor_meeting],current_user)
    flash[:notice] = "#{guest(mentor_meeting).fullname}  will be notified of the cancellation."
    redirect_to mentoring_path
  end

  private

  def meeting_params
    params.require(:mentor_meeting).permit(:purpose,:suggested_meeting_at,:suggested_meeting_time,:duration)
  end

  def feedback_params
    params.require(:mentor_meeting).permit(:user_rating,:mentor_rating,:user_comments,:mentor_comments)
  end

  def meeting_room_accessible
    raise_not_found if !(MentorMeeting.find(params[:id]).status == MentorMeeting::STATUS_STARTED || accepted_and_today?(MentorMeeting.find(params[:id])))
  end

  def accepted_and_today?(mentor_meeting)
    mentor_meeting.status == MentorMeeting::STATUS_ACCEPTED && mentor_meeting.meeting_at.between?(1.day.ago,1.day.from_now)
  end

  def meeting_completed
    raise_not_found if MentorMeeting.find(params[:id]).status != MentorMeeting::STATUS_COMPLETED
  end

  def guest(mentormeeting)
    current_user == mentormeeting.user ? mentormeeting.mentor.user : mentormeeting.user
  end

  def accept_reject_rights
    meeting = MentorMeeting.find(params[:id])
    raise_not_found unless (meeting.requested? && meeting.mentor?(current_user)) || (meeting.rescheduled? && meeting.founder?(current_user))
  end

  def meeting_member
    meeting = MentorMeeting.find(params[:id])
    raise_not_found unless meeting.founder?(current_user) || meeting.mentor?(current_user)
  end

end
