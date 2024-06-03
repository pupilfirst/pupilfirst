module Schools
  class UsersController < ApplicationController
    layout "school"

    before_action :set_user, except: :index
    def index
      authorize(current_school, policy_class: Schools::UserPolicy)

      @users = current_school.users.order(:name).page(params[:page])
    end

    def show
      authorize(@user, policy_class: Schools::UserPolicy)
    end

    def edit
      authorize(@user, policy_class: Schools::UserPolicy)

      @user_roles = @user.discord_roles.where(school: current_school)
      @discord_roles = current_school.discord_roles
      role_ids_from_cohorts = @user.cohorts.pluck(:discord_role_ids).flatten
      @fixed_roles =
        current_school.discord_roles.where(discord_id: role_ids_from_cohorts)
    end

    def update
      authorize(@user, policy_class: Schools::UserPolicy)

      if @user.discord_user_id.blank?
        flash[:error] = "The user does not have a connected Discord profile."
        redirect_to school_user_path(@user)
        return
      end

      role_params = params.require(:user).permit(discord_role_ids: [])

      sync_service =
        Discord::SyncProfileService.new(
          @user,
          additional_discord_role_ids: role_params[:discord_role_ids]
        )

      unless sync_service.sync_ready?
        redirect_to school_user_path(@user)
        return
      end

      if sync_service.execute
        flash[:success] = "Successfully assigned the roles to user."
      else
        flash[
          :error
        ] = "Error assigning roles to user. #{sync_service.error_msg}"
      end

      redirect_to school_user_path(@user)
    end

    private

    def set_user
      @user = current_school.users.find(params["id"])
    end
  end
end
