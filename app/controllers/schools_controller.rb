class SchoolsController < ApplicationController
  before_action :authenticate_user!
  layout 'school'

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

  # GET /school/admins
  def admins
    authorize current_school
  end
end
