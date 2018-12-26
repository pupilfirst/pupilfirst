class SchoolsController < ApplicationController
  layout 'school'

  before_action :courses

  def show
    authorize current_school
  end

  private

  def courses
    @courses ||= policy_scope(Course, policy_scope_class: Schools::CoursePolicy::Scope)
  end
end
