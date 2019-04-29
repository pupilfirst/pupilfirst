class SchoolsController < ApplicationController
  layout 'school'

  before_action :authenticate_school_admin!
  before_action :courses, :teams, :students

  # Enforce authorization with Pundit in all school administration routes.
  after_action :verify_authorized

  # GET /school
  def show
    authorize current_school
  end

  # GET /school/customize
  def customize
    authorize current_school
    render layout: 'settings'
  end

  # POST /school/images
  def images
    authorize current_school

    form = Schools::ImagesForm.new(current_school)

    if form.validate(params)
      form.save

      image_details = Schools::CustomizePresenter.new(view_context).school_images
      image_details[:error] = nil

      render json: image_details
    else
      render json: { error: form.errors.full_messages.join(", ") }
    end
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

  def coaches
    @coaches ||= policy_scope(Faculty, policy_scope_class: Schools::FacultyPolicy::Scope)
  end
end
