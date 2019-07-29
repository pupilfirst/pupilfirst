class ApplicantsController < ApplicationController
  # GET /enroll/:token
  def enroll
    @applicant = authorize(Applicant.find_by(login_token: params[:token]))
    @course = @applicant.course
    render 'courses/apply', layout: 'student'
  end
end
