class StartupLinksController < ApplicationController
  before_filter :authenticate_user!, only: [:create, :destroy]
  before_filter :restrict_to_startup_founders, only: [:create]
  before_filter :restrict_link_to_startup_founders, only: [:delete]

  # GET /startups_links
  def index
    render json: Startup.find(params[:startup_id]).startup_links
  end

  # POST /startup_links
  def create
    startup = Startup.find(params[:startup_id])

    startup_link = startup.startup_links.new(startup_link_params)

    unless startup_link.save
      flash[:alert] = "Failed to create new startup link. Reason: #{startup_link.errors.full_messages.join ', '}"
    end

    redirect_to startup
  end

  # DELETE /startup_links/:id
  def destroy
    StartupLink.find(params[:id]).destroy

    render json: { status: :success }
  end

  private

  def startup_link_params
    params.require(:startup_link).permit(:name, :url, :description)
  end

  def restrict_link_to_startup_founders
    if current_user.startup_id != StartupLink.find(params[:id]).startup_id || !current_user.is_founder?
      raise_not_found
    end
  end

  def restrict_to_startup_founders
    if current_user.startup_id != params[:startup_id].to_i || !current_user.is_founder?
      raise_not_found
    end
  end
end
