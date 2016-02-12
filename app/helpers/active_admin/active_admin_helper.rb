module ActiveAdmin
  module ActiveAdminHelper
    def sv_id_link(user)
      if user.present?
        link_to "#{user.email} - #{user.fullname} #{user.phone.present? ? "(#{user.phone}" : ''})", admin_user_path(user)
      else
        '<em>Missing, probably deleted.</em>'.html_safe
      end
    end

    def stages_collection
      TimelineEventType::STAGES.each_with_object({}) do |stage, hash|
        hash[TimelineEventType::STAGE_NAMES[stage]] = stage
      end
    end

    def startups_by_karma(batch:, after:, before:)
      Startup.joins(:karma_points)
        .where(batch: batch)
        .where(karma_points: { created_at: (after.beginning_of_day..before.end_of_day) })
        .group(:startup_id)
        .sum(:points)
        .sort_by { |_startup_id, points| points }.reverse
    end

    def users_by_karma(batch:, after:, before:)
      Founder.joins(:startup, :karma_points)
        .where(startups: { batch_id: batch.id })
        .where(karma_points: { created_at: (after.beginning_of_day..before.end_of_day) })
        .group(:founder_id)
        .sum(:points)
        .sort_by { |_founder_id, points| points }.reverse
    end
  end
end
