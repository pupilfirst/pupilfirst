class StudentsController < ApplicationController
  # GET /students/:id/report
  def report
    student = authorize(Student.find(params[:id]))
    @course = student.course
    render html: "", layout: "app_router"
  end
end
