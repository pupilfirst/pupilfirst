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

  def founders_profiles_complete?
    founders.all?(&:profile_complete?)
  end

  alias partnership_deed_ready? founders_profiles_complete?
  alias incubation_agreement_ready? founders_profiles_complete?
end
