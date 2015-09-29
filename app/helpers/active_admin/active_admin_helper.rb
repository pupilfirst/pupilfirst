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

    def startups_by_karma(filter)
      if filter
        Startup.joins(:karma_points)
          .where(karma_points: { created_at: (Date.parse(filter[:after]).beginning_of_day..Date.parse(filter[:before]).end_of_day) })
          .group(:startup_id)
          .sum(:points)
      else
        Startup.joins(:karma_points)
          .where('karma_points.created_at > ?', Date.today.beginning_of_week)
          .group(:startup_id)
          .sum(:points)
      end.sort_by { |_startup_id, points| points }.reverse
    end

    def users_by_karma(filter)
      if filter
        User.joins(:karma_points)
          .where(karma_points: { created_at: (Date.parse(filter[:after]).beginning_of_day..Date.parse(filter[:before]).end_of_day) })
          .group(:user_id)
          .sum(:points)
      else
        User.joins(:karma_points)
          .where('karma_points.created_at > ?', Date.today.beginning_of_week)
          .group(:user_id)
          .sum(:points)
      end.sort_by { |_user_id, points| points }.reverse
    end
  end
end
