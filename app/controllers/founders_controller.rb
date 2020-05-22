class FoundersController < ApplicationController
  # GET /students/:id/report
  def report
    student = authorize(Founder.find(params[:id]))
    @course = student.course
    render 'courses/students', layout: 'student_course'
  end
end
