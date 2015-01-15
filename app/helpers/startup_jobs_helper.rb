module StartupJobsHelper
  def display_card?(job)
    !job.expired? || job.can_be_modified_by?(current_user)
  end
end
