class V1::StartupJobsController < V1::BaseController

  def index
    @startup_jobs = StartupJob.all
  end

  def show
    @startup_job = StartupJob.find(params[:id])
  end
  
end
