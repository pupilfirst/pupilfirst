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
      standing_params =
        params.require(:standing).permit(:name, :color, :description)
      @standing = current_school.standings.new(standing_params)

      authorize :standing, policy_class: Schools::StandingPolicy

      if @standing.save
        flash[:success] = I18n.t("schools.standings.create.success")
        redirect_to standing_school_path
      else
        flash.now[:error] = @standing.errors.full_messages.to_sentence
        render :new
      end
    end

    # PATCH /school/standings/:id
    def update
      @standing = current_school.standings.find(params[:id])
      authorize(@standing, policy_class: Schools::StandingPolicy)

      standing_params =
        params.require(:standing).permit(:name, :color, :description)

      if @standing.update(standing_params)
        flash[:success] = I18n.t("schools.standings.update.success")
        redirect_to standing_school_path
      else
        flash.now[:error] = @standing.errors.full_messages.to_sentence
        render :edit
      end
    end

    # DELETE /school/standings/:id
    def destroy
      @standing = current_school.standings.find(params[:id])
      authorize(@standing, policy_class: Schools::StandingPolicy)

      if @standing.user_standings.exists?
        @standing.update!(archived_at: Time.zone.now)
        flash[:success] = I18n.t("schools.standings.delete.archive_success")
      else
        @standing.destroy!
        flash[:success] = I18n.t("schools.standings.delete.success")
      end

      redirect_to standing_school_path
    end
  end
end
