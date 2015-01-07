class StartupJobsController < ApplicationController
  before_filter :authenticate_user!, except: [:show, :list_all, :index]
  before_filter :restrict_to_startup_founders, only: [:new, :create, :repost]
  
  def new
    @startup = Startup.find(params[:startup_id])
    @startup_job = @startup.startup_jobs.new 
  end
  
  def create
    @startup = Startup.find(params[:startup_id])
    @startup_jobs = @startup.startup_jobs.new(startup_job_params)
    @startup_jobs.update_attributes(expires_on: Time.now.days_since(60))
    if @startup_jobs.save
      redirect_to startup_startup_jobs_path(@startup, @startup_jobs)
    else
      render 'new'
    end

  end

  def show
    @startup = Startup.find(params[:startup_id])
    @startup_job = @startup.startup_jobs.find(params[:id])
  end

  def index
    @startup = Startup.find(params[:startup_id])
    @startup_jobs = @startup.startup_jobs.all
    @startup_founder = disallow_unauthenticated_repost
  end

  def list_all
    @startup_jobs = StartupJob.all
  end

  def repost
    @startup = Startup.find(params[:startup_id])
    @startup_job = @startup.startup_jobs.find(params[:startup_job_id])
    @startup_job.expires_on = (Time.now.days_since (60))
    if @startup_job.save
      redirect_to startup_startup_jobs_path(@startup,@startup_job)
    else
      render 'new'
    end
  end

  private
  def startup_job_params
    params.require(:startup_job).permit(:title, :description, :salary_max, :salary_min, :equity_max, :equity_min, :equity_vest, :equity_cliff)
  end


  def restrict_to_startup_founders
    if current_user.startup.try(:id) != params[:startup_id].to_i || !current_user.is_founder?
      raise_not_found
    end
  end 

  def disallow_unauthenticated_repost
    if current_user.present?
      if ((current_user.startup.try(:id) == params[:startup_id].to_i) && (current_user.is_founder?))
        true
      else
        false
      end
    end
  end

end