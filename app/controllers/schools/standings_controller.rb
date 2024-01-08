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

      begin
        @standing = current_school.standings.create!(standing_params)
        flash[:success] = I18n.t("schools.standings.create.success")
        redirect_to standing_school_path
      rescue ActiveRecord::RecordInvalid => e
        flash.now[:error] = e.message
        render :new
      end
    end

    # PATCH /school/standings/:id
    def update
      @standing = current_school.standings.find(params[:id])
      authorize(@standing, policy_class: Schools::StandingPolicy)

      standing_params =
        params.require(:standing).permit(:name, :color, :description)
      @standing.update!(standing_params)

      flash[:success] = I18n.t("schools.standings.update.success")

      redirect_to standing_school_path
    end

    # DELETE /school/standings/:id
    def destroy
      @standing = current_school.standings.find(params[:id])
      authorize(@standing, policy_class: Schools::StandingPolicy)

      if @standing.user_standings.count > 0
        @standing.update!(archived_at: Time.zone.now)
      else
        @standing.destroy!
      end

      flash[:success] = I18n.t("schools.standings.delete.success")

      redirect_to standing_school_path
    end
  end
end
