module StartupJobsHelper
  def display_card?(job, startup_founder)
    job.expires_on > Time.now || startup_founder
  end
end
