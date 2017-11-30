module TimelineEvents
  class ReviewDataService
    include RoutesResolvable

    def data
      TimelineEvent.pending.includes(:timeline_event_type, { founder: :user }, { startup: :level }, { target: { target_performance_criteria: :performance_criterion } }, { improvement_of: :timeline_event_type }, :timeline_event_files).order('timeline_events.created_at').each_with_object({}) do |event, hash|
        hash[event.id] = {
          event_id: event.id,
          title: event.title,
          event_on: event.event_on.strftime('%b %d, %Y'),
          created_at: event.created_at.strftime('%b %d %H:%M'),
          description: event.description,
          feedback_url: feedback_url(event),
          level_scope: level_scope(event)
        }

        hash[event.id] = merge_attachment_details(event, hash[event.id])
        hash[event.id] = merge_owner_details(event, hash[event.id])
        hash[event.id] = merge_target_details(event, hash[event.id])
      end
    end

    private

    def merge_attachment_details(event, hash)
      hash.merge(
        links: event.links,
        files: event.timeline_event_files,
        image: event.image_filename
      )
    end

    def merge_owner_details(event, hash)
      hash.merge(
        user_id: event.founder.user.id,
        founder_id: event.founder_id,
        founder_name: event.founder.name,
        startup_id: event.startup_id,
        startup_name: event.startup.product_name,
        impersonate_url: impersonate_url(event)
      )
    end

    def merge_target_details(event, hash)
      hash.merge(
        target_id: event.target_id,
        target_title: event.target&.title,
        improvement_of: event.improvement_of,
        improvement_of_title: event.improvement_of&.title,
        rubric: rubric_details(event.target)
      )
    end

    def rubric_details(target)
      if target&.target_performance_criteria.present?
        target.target_performance_criteria.each_with_object({}) do |tpc, pc_hash|
          pc_hash[tpc.performance_criterion_id] = {
            description: tpc.performance_criterion.description,
            rubric_good: tpc.rubric_good,
            rubric_great: tpc.rubric_great,
            rubric_wow: tpc.rubric_wow
          }
        end
      end
    end

    def feedback_url(timeline_event)
      url_helpers.new_admin_startup_feedback_path(
        startup_feedback: {
          startup_id: timeline_event.startup.id,
          timeline_event_id: timeline_event.id
        }
      )
    end

    def impersonate_url(timeline_event)
      url_helpers.impersonate_admin_user_url(timeline_event.founder.user, referer: timeline_event.share_url)
    end

    def level_scope(event)
      event.startup.level.number.positive? ? 'admitted' : 'levelZero'
    end
  end
end
