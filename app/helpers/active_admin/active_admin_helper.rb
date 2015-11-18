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
      # set default constraints if not supplied by filter
      batch_number = filter && filter[:batch].present? ? filter[:batch] : 1
      start_date = filter && filter[:after].present? ? Date.parse(filter[:after]) : Date.today.beginning_of_week
      end_date = filter && filter[:before].present? ? Date.parse(filter[:before]) : Date.today
      Startup.joins(:karma_points)
        .where(batch: batch_number)
        .where(karma_points: { created_at: (start_date.beginning_of_day..end_date.end_of_day) })
        .group(:startup_id)
        .sum(:points)
        .sort_by { |_startup_id, points| points }.reverse
    end

    def users_by_karma(filter)
      # set default constraints if not supplied by filter
      batch_number = filter && filter[:batch].present? ? filter[:batch] : 1
      start_date = filter && filter[:after].present? ? Date.parse(filter[:after]) : Date.today.beginning_of_week
      end_date = filter && filter[:before].present? ? Date.parse(filter[:before]) : Date.today
      User.joins(:startup, :karma_points)
        .where(startups: { batch: batch_number })
        .where(karma_points: { created_at: (start_date.beginning_of_day..end_date.end_of_day) })
        .group(:user_id)
        .sum(:points)
        .sort_by { |_user_id, points| points }.reverse
    end
  end
end
