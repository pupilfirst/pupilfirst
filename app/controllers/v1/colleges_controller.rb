class V1::CollegesController < V1::BaseController
  skip_before_filter :require_token

  api :GET, '/colleges', "List of all Colleges"
  def index
    @colleges = College.all
    respond_to do |format|
      format.json
    end
  end

end
