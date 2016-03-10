module ActiveAdmin
  module ActiveAdminHelper
    def sv_id_link(founder)
      if founder.present?
        link_to "#{founder.email} - #{founder.fullname} #{founder.phone.present? ? "(#{founder.phone}" : ''})", admin_founder_path(founder)
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

    def founders_by_karma(batch:, after:, before:)
      Founder.joins(:startup, :karma_points)
        .where(startups: { batch_id: batch.id })
        .where(karma_points: { created_at: (after.beginning_of_day..before.end_of_day) })
        .group(:founder_id)
        .sum(:points)
        .sort_by { |_founder_id, points| points }.reverse
    end

    # Returns links to tags separated by a separator string.
    def linked_tags(tags, separator: ', ')
      return unless tags.present?

      tags.map do |tag|
        link_to tag.name, admin_tag_path(tag)
      end.join(separator).html_safe
    end

    # Return a string explaining details of reaction received on public slack
    def reaction_details(message)
      reaction_to_author = message.reaction_to.founder.present? ? message.reaction_to.founder.fullname : message.reaction_to.slack_username
      "reacted with #{message.body} to \'#{truncate(message.reaction_to.body, length: 250)}\' from #{reaction_to_author}"
    end
  end
end
