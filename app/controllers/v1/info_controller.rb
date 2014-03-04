class V1::InfoController < V1::BaseController

  skip_before_filter :require_token, only: [:mentors, :advisory_council, :startup_stats]

  def mentors
    respond_to do |format|
        format.json
    end
  end

  def advisory_council
    respond_to do |format|
        format.json
    end
  end

  def startup_stats
    respond_to do |format|
        format.json
    end
  end
end
