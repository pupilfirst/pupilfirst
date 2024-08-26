module Schools
  class UsersController < ApplicationController
    layout "school"

    before_action :set_user, except: :index
    after_action :verify_authorized, except: :index
    after_action :verify_policy_scoped, only: :index

    # GET school/users
    def index
      authorize([:schools, current_user])
      @users = policy_scope([:schools, User])

      @presenter = Schools::Users::IndexPresenter.new(view_context, @users)
    end

    # GET school/users/:id
    def show
      authorize([:schools, @user])

      @presenter = Schools::Users::ShowPresenter.new(view_context, @user)
    end

    # GET school/users/:id/edit
    def edit
      authorize([:schools, @user])

      cohort_roles =
        @user.cohorts.map { |c| { name: c.name, role_ids: c.discord_role_ids } }
      fixed_role_ids = cohort_roles.flat_map { |c| c[:role_ids] }

      @fixed_roles =
        current_school
          .discord_roles
          .where(discord_id: fixed_role_ids)
          .map do |role|
            cohort_name =
              cohort_roles.find do |cr|
                cr[:role_ids].include?(role.discord_id)
              end[
                :name
              ]
            OpenStruct.new(
              cohort_name: cohort_name,
              role_name: role.name,
              role_color: role.color_hex
            )
          end

      @discord_roles =
        current_school.discord_roles.where.not(discord_id: fixed_role_ids)

      @user_roles = @user.discord_roles.where.not(discord_id: fixed_role_ids)
    end

    # PATCH /school/users/:id
    def update
      authorize([:schools, @user])

      unless Schools::Configuration::Discord.new(current_school).configured?
        flash[:error] = t(".add_discord_config")

        redirect_to edit_school_user_path(@user)
        return
      end

      if @user.discord_user_id.blank?
        flash[:error] = t(".user_has_not_connected_discord")
        redirect_to school_user_path(@user)
        return
      end

      role_params = params.require(:user).permit(discord_role_ids: [])

      sync_service =
        Discord::SyncProfileService.new(
          @user,
          additional_discord_role_ids: role_params[:discord_role_ids]
        )

      sync_service.execute

      if sync_service.warning_msg.blank?
        flash[:success] = t(".successfully_synced_roles")
      elsif sync_service.warning_msg.present?
        flash[:warning] = sync_service.warning_msg
      end

      redirect_to school_user_path(@user)
    rescue Discord::SyncProfileService::SyncError => e
      flash[:error] = e.message

      redirect_to school_user_path(@user)
    end

    private

    def set_user
      @user = policy_scope([:schools, User]).find(params["id"])
    end
  end
end
