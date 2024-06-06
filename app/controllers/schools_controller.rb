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
  def discord
    authorize current_school
    @tab = params["tab"] || "configuration"
    @discord_config = Schools::Configuration::Discord.new(current_school)
    @discord_roles = current_school.discord_roles
  end

  # PATCH /school/discord_configuration
  def discord_configuration
    authorize current_school

    server_id = params["server_id"]
    bot_token = params["bot_token"]
    bot_user_id = params["bot_user_id"]

    discord_config = current_school.configuration.dig("discord") || {}
    discord_config["server_id"] = server_id.presence ||
      discord_config.dig("server_id")
    discord_config["bot_user_id"] = bot_user_id.presence ||
      discord_config.dig("bot_user_id")
    discord_config["bot_token"] = bot_token.presence ||
      discord_config.dig("bot_token")

    current_school.update!(
      configuration: current_school.configuration.merge(discord_config)
    )

    flash[:success] = "Successfully stored the Discord server configuration."

    redirect_to discord_school_path
  end

  # POST /school/discord_sync_roles
  def discord_sync_roles
    authorize current_school

    role_sync_service = Discord::SyncRolesService.new(school: current_school)

    if role_sync_service.sync
      flash[
        :success
      ] = "Successfully synced server roles that are under Bot role."
    else
      flash[:error] = "Failed to sync roles. #{role_sync_service.error_message}"
    end

    redirect_to discord_school_path
  end

  # GET /school/
  def school_router
    authorize current_school
    render html: "", layout: "school_router"
  end
end
