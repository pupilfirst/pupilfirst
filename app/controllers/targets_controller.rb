class TargetsController < ApplicationController
  include CamelizeKeys
  include StringifyIds

  before_action :authenticate_user!

  # GET /targets/:id/(:slug)
  def show
    target = authorize(Target.find(params[:id]))
    @course = target.course
    @presenter = Targets::ShowPresenter.new(view_context, target)
    render 'courses/curriculum', layout: 'student_course'
  end

  # GET /targets/:id/details
  def details_v2
    target = authorize(Target.find(params[:id]))
    student = current_user.founders.joins(:course).where(courses: { id: target.course }).first
    render json: camelize_keys(stringify_ids(Targets::DetailsService.new(target, student).details))
  end
end
