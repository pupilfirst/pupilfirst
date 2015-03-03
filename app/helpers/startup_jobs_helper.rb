module StartupJobsHelper
  def display_card?(job)
    if job.startup.present?
      !job.expired? || job.can_be_modified_by?(current_user)
    else
      logger.warn "Skipping display of job from missing startup with ID #{job.startup_id}"
      false
    end
  end

  def value_or_not_available(value)
    if value.blank?
      '<em>Not Available</em>'.html_safe
    else
      value
    end
  end

  def equity_html(job)
    equity = "#{job.equity_min}%"

    if job.equity_max.present?
      equity += " &ndash; #{job.equity_max}%"
    end

    if job.equity_vest.present? && job.equity_cliff.present?
      equity += " (#{job.equity_vest} year vest with #{job.equity_cliff} year cliff)"
    end

    equity.html_safe
  end
end
