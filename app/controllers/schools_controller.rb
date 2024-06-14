class SchoolsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_discord_roles,
                only: %i[discord_configuration discord_server_roles]
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

  def discord_server_roles
    authorize current_school

    if params[:cause].present? && params[:cause] == "DeletedRoles"
      @sync_service = Discord::SyncRolesService.new(school: current_school)
    end
  end

  # PATCH /school/discord_configuration
  def discord_credentials
    authorize current_school

    bot_token = params["bot_token"]

    discord_config = current_school.configuration.dig("discord") || {}
    discord_config["server_id"] = params["server_id"]
    discord_config["bot_user_id"] = params["bot_user_id"]
    discord_config["bot_token"] = bot_token.presence ||
      discord_config.dig("bot_token")

    current_school.update!(
      configuration:
        current_school.configuration.merge({ "discord" => discord_config })
    )

    flash[:success] = "Successfully stored the Discord server configuration."

    redirect_to discord_configuration_school_path
  end

  # POST /school/discord_sync_roles
  def discord_sync_roles
    authorize current_school

    role_sync_service = Discord::SyncRolesService.new(school: current_school)

    if (
         role_sync_service.sync_ready? && role_sync_service.deleted_roles.blank?
       ) || (role_sync_service.sync_ready? && params[:confirmed_sync].present?)
      role_sync_service.sync
      flash[
        :success
      ] = "Successfully synced server roles that are under Bot role."
    elsif role_sync_service.deleted_roles.present?
      redirect_to discord_server_roles_school_path(cause: "DeletedRoles")
      flash[:warn] = "Please confirm action before caching server roles."

      return
    else
      flash[:error] = "Failed to sync roles. #{role_sync_service.error_message}"
    end

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
    @discord_roles = current_school.discord_roles.order(position: :desc)
    @school_logo_url =
      view_context.rails_public_blob_url(current_school.icon_variant(:thumb))
  end
end
