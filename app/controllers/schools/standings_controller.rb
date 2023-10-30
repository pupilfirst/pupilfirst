module Schools
  class StandingsController < SchoolsController
    layout "school"

    # GET /school/standings/new
    def new
      @standing = Standing.new
      authorize(@standing, policy_class: Schools::StandingPolicy)
    end

    # GET /school/standings/:id/edit
    def edit
      @standing = current_school.standings.find(params[:id])
      authorize(@standing, policy_class: Schools::StandingPolicy)
    end

    # POST /school/standings
    def create
      @standing = Standing.new
      authorize(@standing, policy_class: Schools::StandingPolicy)

      standing_params =
        params.require(:standing).permit(:name, :color, :description)

      @standing = current_school.standings.create!(standing_params)

      flash[:success] = I18n.t("standings.create.success")

      redirect_to standing_school_path
    end

    # PATCH /school/standings/:id
    def update
      @standing = current_school.standings.find(params[:id])
      authorize(@standing, policy_class: Schools::StandingPolicy)

      if params[:standing].blank?
        @standing.update!(archived_at: Time.zone.now)
      else
        standing_params =
          params.require(:standing).permit(:name, :color, :description)
        @standing.update!(standing_params)
      end

      flash[:success] = I18n.t("standings.update.success")

      redirect_to standing_school_path
    end

    def destroy
      @standing = current_school.standings.find(params[:id])
      authorize(@standing, policy_class: Schools::StandingPolicy)

      @standing.update!(archived_at: Time.zone.now)

      flash[:success] = I18n.t("standings.destroy.success")

      redirect_to standing_school_path
    end
  end
end
