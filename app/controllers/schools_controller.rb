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

  # PATCH /school/standing
  def toggle_standing
    authorize current_school

    standing_enabled = params[:enable_standing] == "true" ? true : false

    begin
      if current_school.standings.count == 0 && standing_enabled
        update_standing_configuration(standing_enabled)

        Standing.create!(
          name:
            I18n.t("schools.standing.toggle_standing.default_standing_name"),
          color: "#4338ca",
          description:
            I18n.t(
              "schools.standing.toggle_standing.default_standing_description"
            ),
          school: current_school,
          default: true
        )
      else
        update_standing_configuration(standing_enabled)
      end
      flash[:success] = I18n.t(
        "schools.standing.toggle_standing.school_standing_toggle_success.#{params[:enable_standing] == "true" ? "_yes" : "_no"}"
      )
    rescue ActiveRecord::RecordInvalid => e
      flash[:error] = e.message
    end

    redirect_to standing_school_path
  end

  # GET /school/code_of_conduct
  def code_of_conduct
    authorize current_school
    @code_of_conduct = SchoolString::CodeOfConduct.for(current_school)
  end

  # PATCH /school/code_of_conduct
  def update_code_of_conduct
    authorize current_school
    value = params[:code_of_conduct_editor].strip
    if SchoolString.exists?(school: current_school, key: "code_of_conduct") &&
         value.length > 0
      SchoolString.find_by(
        school: current_school,
        key: "code_of_conduct"
      ).update!(value: value)
    elsif value.length > 0
      SchoolString.create!(
        school: current_school,
        key: "code_of_conduct",
        value: value
      )
    else
      SchoolString.find_by(
        school: current_school,
        key: "code_of_conduct"
      ).destroy
    end
    flash[:success] = I18n.t("schools.standing.save_coc_success")
    redirect_to standing_school_path
  end

  # GET /school/
  def school_router
    authorize current_school
    render html: "", layout: "school_router"
  end

  private

  def update_standing_configuration(value)
    current_school.update(
      configuration:
        current_school.configuration.merge("enable_standing" => value)
    )
  end
end
