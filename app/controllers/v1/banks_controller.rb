class V1::BanksController < V1::BaseController

  def create
    startup = Startup.find(params[:startup_id]) rescue nil
    startup ||= current_user.startup
    attrib = bank_params.merge(startup: startup)
    if Bank.create(attrib)
      render json: {message: "message"}, status: :created
    else
      render json: {error:"Error creating Bank"}, status: :bad_request
    end
  end

private

  def bank_params
    params.require(:bank).permit(:name, :is_joint)
  end
end
