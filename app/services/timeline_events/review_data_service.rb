module TimelineEvents
  class ReviewDataService
    include RoutesResolvable

    def initialize(batch)
      @batch = batch
    end

    def data
      batch_timeline_events.pending.includes(:timeline_event_type, [founder: :user], :startup, :target, :timeline_event_files, [improvement_of: :timeline_event_type]).order('timeline_events.created_at').each_with_object({}) do |event, hash|
        hash[event.id] = {
          event_id: event.id,
          title: event.title,
          user_id: event.founder.user.id,
          event_on: event.event_on.strftime('%b %d, %Y'),
          created_at: event.created_at.strftime('%b %d %H:%M'),
          description: event.description,
          feedback_url: feedback_url(event)
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
        improvement_of_title: event.improvement_of&.title
      )
    end

    def batch_timeline_events
      TimelineEvent.where(founder: @batch.founders)
    end

    def feedback_url(timeline_event)
      url_helpers.new_admin_startup_feedback_path(
        startup_feedback: {
          startup_id: timeline_event.startup.id,
          reference_url: url_helpers.startup_url(timeline_event.startup, anchor: "event-#{timeline_event.id}"),
          event_id: timeline_event.id
        }
      )
    end

    def impersonate_url(timeline_event)
      url_helpers.impersonate_admin_user_url(timeline_event.founder.user, referer: timeline_event.share_url)
    end
  end
end
