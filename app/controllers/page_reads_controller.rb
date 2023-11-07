class PageReadsController < ApplicationController
  #TODO - add authentication and authorization for the request

  def create
    student =
      current_user
        .students
        .joins(:course)
        .where(courses: { id: course.id })
        .first if current_user.present?
    @page_read = PageRead.new(target_id: params[:target_id], student_id: student.id)
    if @page_read.save
      render json: @page_read, status: :created
    else
      render json: @page_read.errors, status: :unprocessable_entity
    end
  end

  def destroy
    @page_read = PageRead.find(params[:id])
    @page_read.destroy
    head :no_content
  end

  def course
    Target.find(params[:target_id]).course
  end
end
