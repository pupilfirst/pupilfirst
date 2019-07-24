class SchoolsController < ApplicationController
  layout 'school'

  before_action :courses, :teams

  # Enforce authorization with Pundit in all school administration routes.
  after_action :verify_authorized

  # GET /school
  def show
    authorize current_school
  end

  # GET /school/customize
  def customize
    authorize current_school
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

  def teams
    @teams ||= policy_scope(Startup, policy_scope_class: Schools::StartupPolicy::Scope)
  end
end
