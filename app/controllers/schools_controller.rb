class SchoolsController < ApplicationController
  layout 'school'

  before_action :courses

  # Enforce authorization with Pundit in all school administration routes.
  after_action :verify_authorized

  def show
    authorize current_school
  end

  private

  def courses
    @courses ||= policy_scope(Course, policy_scope_class: Schools::CoursePolicy::Scope)
  end
end
