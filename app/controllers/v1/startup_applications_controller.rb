class V1::StartupApplicationsController < V1::BaseController
  def create
  	StartupApplication.create!(startup_application_params)
  	render json: {success: true}
  end

private
  def startup_application_params
    params.require(:startup_application).permit(:name, :email, :phone, :idea, :website)
  end

end
