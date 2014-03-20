class V1::BanksController < V1::BaseController

  def create
    startup = Startup.find(params[:startup_id]) rescue nil
    startup ||= current_user.startup
    attrib = bank_params.merge(startup: startup)
    attrib[:director_ids] = [current_user.id] if attrib[:director_ids].nil?
    if Bank.create(attrib)
      render json: {message: "message"}, status: :created
    else
      render json: {error:"Error creating Bank"}, status: :bad_request
    end
  end

private

  def bank_params
    params.require(:bank).permit(:name, :director_ids, :is_joint)
  end
end
