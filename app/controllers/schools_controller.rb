class SchoolsController < ApplicationController
  before_action :authenticate_user!
  layout "school"

  # Enforce authorization with Pundit in all school administration routes.
  after_action :verify_authorized

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

      image_details =
        Schools::CustomizePresenter.new(view_context).school_images
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

  # GET /school/standing
  def standing
    authorize current_school
    @presenter = Schools::StandingPresenter.new(view_context, current_school)
  end

  def toggle_standing
    authorize current_school

    if current_school.standings.count == 0 && params[:enable_standing] == "true"
      update_stading_configuration

      Standing.create!(
        name: "Neutral",
        color: "#D3D3D3",
        description: "This is the default standing for all students.",
        school: current_school,
        default: true
      )
    else
      update_stading_configuration
    end

    redirect_to standing_school_path
  end

  # GET /school/
  def school_router
    authorize current_school
    render html: "", layout: "school_router"
  end

  private

  def update_stading_configuration
    current_school.update(
      configuration:
        current_school.configuration.merge(
          "enable_standing" =>
            ActiveRecord::Type::Boolean.new.cast(params[:enable_standing])
        )
    )
  end
end
