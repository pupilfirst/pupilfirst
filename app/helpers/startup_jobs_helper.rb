module StartupJobsHelper
  def display_card?(job)
    if job.startup.present?
      !job.expired? || job.can_be_modified_by?(current_user)
    else
      logger.warn "Skipping display of job from missing startup with ID #{job.startup_id}"
      false
    end
  end
end
