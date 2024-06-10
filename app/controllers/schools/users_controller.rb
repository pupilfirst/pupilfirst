module Schools
  class UsersController < ApplicationController
    layout "school"

    before_action :set_user, except: :index
    def index
      authorize(current_school, policy_class: Schools::UserPolicy)

      @presenter = Schools::UsersIndexPresenter.new(view_context)
    end

    def show
      authorize(@user, policy_class: Schools::UserPolicy)

      @show_presenter = Schools::UsersShowPresenter.new(view_context, @user)
    end

    def edit
      authorize(@user, policy_class: Schools::UserPolicy)

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

      @user_roles =
        @user
          .discord_roles
          .where(school: current_school)
          .where.not(discord_id: fixed_role_ids)
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
