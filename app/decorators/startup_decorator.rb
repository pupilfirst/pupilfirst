class StartupDecorator < Draper::Decorator
  delegate_all

  def identicon_logo
    base64_logo = Startups::IdenticonLogoService.new(model).base64_svg
    h.image_tag("data:image/svg+xml;base64,#{base64_logo}", class: 'founder-dashboard-header__startup-logo')
  end

  def completed_targets_count
    timeline_events.verified_or_needs_improvement.where.not(target_id: nil).distinct.count(:target_id)
  end

  def completed_targets_percentage
    targets_count = Target.count
    return 0 unless targets_count.positive?
    ((completed_targets_count.to_f / targets_count) * 100).to_i
  end

  def leaderboard_rank
    performance_service.leaderboard_rank(model) || '?'
  end

  def last_week_karma
    performance_service.last_week_karma(model)
  end

  def relative_performance
    performance_service.relative_performance(model)
  end

  def performance_label
    case relative_performance
      when 10 then 'Below Average'
      when 30 then 'Average'
      when 50 then 'Good'
      when 70 then 'Great'
      when 90 then 'Wow'
    end
  end

  def performance_service
    @performance_service ||= Startups::PerformanceService.new
  end

  def founders_profiles_complete?
    founders.all?(&:profile_complete?)
  end

  alias partnership_deed_ready? founders_profiles_complete?
  alias incubation_agreement_ready? founders_profiles_complete?
end
