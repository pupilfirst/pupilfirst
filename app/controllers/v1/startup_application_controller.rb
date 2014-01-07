class V1::StartupApplicationController < V1::BaseController
  def create
  	puts params
  	StartupApplication.create!(params[:startup_application])
  	render json: {success: true}
  end

private
  def startup_application_params
    params.require(:startup_application).permit(:name, :email, :phone, :idea, :website)
  end

end
