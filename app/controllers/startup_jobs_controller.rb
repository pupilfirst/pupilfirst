class StartupJobsController < ApplicationController
  before_filter :authenticate_user!, except: [:show, :list_all, :index]
  before_filter :restrict_to_startup_founders_with_live_agreement, only: [:new, :create, :repost]

  def new
    @startup = Startup.find params[:startup_id]
    @startup_job = @startup.startup_jobs.new
  end

  def create
    @startup = Startup.find params[:startup_id]
    @startup_job = @startup.startup_jobs.new startup_job_params

    if @startup_job.save
      redirect_to startup_startup_jobs_path @startup
    else
      render 'new'
    end
  end

  def show
    @startup = Startup.find params[:startup_id]
    @startup_job = @startup.startup_jobs.find params[:id]
  end

  def index
    @startup = Startup.find params[:startup_id]
    @startup_jobs = @startup.startup_jobs.order('updated_at DESC')
  end

  def list_all
    @startup_jobs = StartupJob.includes(:startup).order('updated_at DESC')
  end

  def edit
    @startup = Startup.find params[:startup_id]
    @startup_job = @startup.startup_jobs.find params[:id]
  end

  def update
    @startup = Startup.find params[:startup_id]
    @startup_job = @startup.startup_jobs.find params[:id]
    if @startup_job.update(startup_job_params)
      redirect_to startup_startup_jobs_path @startup
    else
      render 'edit'
    end
  end

  def repost
    @startup = Startup.find params[:startup_id]
    @startup_job = @startup.startup_jobs.find params[:startup_job_id]
    @startup_job.reset_expiry!
    @startup_job.save!

    redirect_to startup_startup_jobs_path(@startup, @startup_job)
  end

  def destroy
    @startup = Startup.find params[:startup_id]
    @startup_job = @startup.startup_jobs.find params[:id]
    @startup_job.destroy!

    redirect_to startup_startup_jobs_path(@startup, @startup_job)
  end

  private

  def startup_job_params
    params.require(:startup_job).permit(
      :title, :location, :description, :equity_max, :equity_min, :equity_vest, :equity_cliff, :skills, :experience,
      :qualification, :contact_name, :contact_number, :contact_email, :salary
    )
  end

  def restrict_to_startup_founders_with_live_agreement
    if current_user.startup.try(:id) != params[:startup_id].to_i || !current_user.is_founder?
      raise_not_found
    elsif !current_user.startup.agreement_live?
      flash[:alert] = 'Your do have an active agreement with Startup Village. Please enter into agreement with SV to post jobs listings.'
      redirect_to current_user.startup
    end
  end

  def disallow_unauthenticated_repost
    (current_user.try(:startup).try(:id) == params[:startup_id].to_i) && (current_user.try(:is_founder?))
  end
end
