class SchoolsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_discord_roles,
                only: %i[
                  discord_configuration
                  discord_server_roles
                  discord_sync_roles
                ]
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

  # PATCH /school/toggle_standing
  def toggle_standing
    authorize current_school

    standing_enabled = params[:enable_standing] == "true"

    Standing.transaction do
      current_school.update!(
        configuration:
          current_school.configuration.merge(
            "enable_standing" => standing_enabled
          )
      )

      if standing_enabled && !current_school.standings.exists?
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
      end
    end

    flash[:success] = I18n.t(
      "schools.standing.toggle_standing.school_standing_toggle_success.#{standing_enabled == true ? "_yes" : "_no"}"
    )

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
    school_string =
      current_school.school_strings.find_by(key: "code_of_conduct")

    if school_string.present? && value.present?
      school_string.update!(value: value)
    elsif value.present?
      current_school.school_strings.create!(
        key: "code_of_conduct",
        value: value
      )
    else
      school_string&.destroy
    end

    flash[:success] = I18n.t("schools.standing.save_coc_success")
    redirect_to standing_school_path
  end

  # GET /school/discord
  def discord_configuration
    authorize current_school
  end

  # GET /school/discord_server_roles
  def discord_server_roles
    authorize current_school
  end

  # PATCH /school/discord_credentials
  def discord_credentials
    authorize current_school

    form = Schools::DiscordConfigurationForm.new(Reform::OpenForm.new)

    form.current_school = current_school

    if form.validate(params)
      form.save

      flash[:success] = t(".discord_config_stored")
    else
      flash[:error] = form.errors.full_messages.join(", ")
    end

    redirect_to discord_configuration_school_path
  end

  # POST /school/discord_sync_roles
  def discord_sync_roles
    authorize current_school

    @sync_service = Discord::SyncRolesService.new(school: current_school)

    if @sync_service.deleted_roles? && params[:confirmed].blank?
      flash.now[:warn] = t(".sync_service_result.warn")
      return
    else
      @sync_service.save

      flash[:success] = t(".sync_service_result.success")
    end

    redirect_to discord_server_roles_school_path
  rescue Discord::SyncRolesService::SyncError
    flash[:error] = t(".sync_service_result.warn")

    redirect_to discord_server_roles_school_path
  end

  # POST /school/update_default_discord_roles
  def update_default_discord_roles
    authorize current_school

    roles = current_school.discord_roles

    roles.where(id: params[:default_role_ids]).update_all(default: true) # rubocop:disable Rails/SkipsModelValidations
    roles
      .where.not(id: params[:default_role_ids])
      .where(default: true)
      .update_all(default: false) # rubocop:disable Rails/SkipsModelValidations

    flash[:success] = t(".updated_default_roles")

    redirect_to discord_server_roles_school_path
  end

  # GET /school/
  def school_router
    authorize current_school
    render html: "", layout: "school_router"
  end

  private

  def set_discord_roles
    @discord_config = Schools::Configuration::Discord.new(current_school)
    @discord_roles = transform_discord_roles
    @school_logo_url =
      if current_school.icon_on_light_bg.attached?
        view_context.rails_public_blob_url(current_school.icon_variant(:thumb))
      else
        "/favicon.png"
      end
  end

  def transform_discord_roles
    db_roles =
      current_school.discord_roles.includes(:users).order(position: :desc)
    default_role_ids = current_school.default_discord_role_ids || []

    db_roles.map do |role|
      OpenStruct.new(
        {
          id: role.id,
          name: role.name,
          color_hex: role.color_hex,
          is_default: role.discord_id.in?(default_role_ids),
          member_count: role.users.size
        }
      )
    end
  end
end
