class SchoolsController < ApplicationController
  layout 'school'

  before_action :authenticate_school_admin!
  before_action :courses, :teams, :students

  # Enforce authorization with Pundit in all school administration routes.
  after_action :verify_authorized

  def show
    authorize current_school
  end

  private

  def courses
    @courses ||= policy_scope(Course, policy_scope_class: Schools::CoursePolicy::Scope)
  end

  def students
    @students ||= policy_scope(Founder, policy_scope_class: Schools::FounderPolicy::Scope)
  end

  def teams
    @teams ||= policy_scope(Startup, policy_scope_class: Schools::StartupPolicy::Scope)
  end
end
