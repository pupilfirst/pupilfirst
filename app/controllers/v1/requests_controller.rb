class V1::RequestsController < V1::BaseController
  # GET /api/requests
  def index
    @requests = current_user.requests
  end

  # POST /api/requests
  def create
    unless current_user.startup
      raise Exceptions::UserDoesNotBelongToStartup, 'User must belong to a startup to submit requests.'
    end

    request = Request.new request_params
    request.user = current_user
    request.save!
    render nothing: true
  end

  private

  def request_params
    params.require(:request).permit(:body)
  end
end
