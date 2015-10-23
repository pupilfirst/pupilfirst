ActiveAdmin.register_page 'Dashboard' do
  menu priority: 1

  content do
    div class: 'dashboard-container' do
      div class: 'dashboard-item' do
        timeline_events_verified = TimelineEvent.verified.order('verified_at DESC').includes(:timeline_event_type, :startup)

        div class: 'heading' do
          'Timeline Events - Verified'
        end

        div class: 'content' do
          ol do
            timeline_events_verified.limit(10).each do |timeline_event|
              li do
                link_to "#{timeline_event.startup.product_name} - #{timeline_event.timeline_event_type.title}", admin_timeline_event_path(timeline_event)
              end
            end
          end
        end

        div class: 'footer-spacer'

        div class: 'left-of-button' do
          "Verified less than 3 weeks ago: #{timeline_events_verified.where('verified_at > ?', 3.weeks.ago).count}"
        end

        a href: admin_timeline_events_path(q: { verified_status_equals: TimelineEvent::VERIFIED_STATUS_VERIFIED }), class: 'button view-all' do
          "View All (#{timeline_events_verified.count})"
        end
      end

      div class: 'dashboard-item' do
        timeline_events_pending = TimelineEvent.pending.order('created_at DESC').includes(:timeline_event_type, :startup)

        div class: 'heading' do
          'Timeline Events - Pending'
        end

        div class: 'content' do
          ol do
            timeline_events_pending.limit(10).each do |timeline_event|
              li do
                link_to "#{timeline_event.startup.product_name} - #{timeline_event.timeline_event_type.title}", admin_timeline_event_path(timeline_event)
              end
            end
          end
        end

        div class: 'footer-spacer'

        div class: 'footer' do
          div class: 'left-of-button' do
            "Created less than 3 weeks ago: #{timeline_events_pending.where('created_at > ?', 3.weeks.ago).count}"
          end

          a href: admin_timeline_events_path(q: { verified_status_equals: TimelineEvent::VERIFIED_STATUS_PENDING }), class: 'button view-all' do
            "View All (#{timeline_events_pending.count})"
          end
        end
      end

      div class: 'dashboard-item' do
        startups_without_live_targets = Startup.without_live_targets

        div class: 'heading' do
          'Startups without Live Team Targets'
        end

        div class: 'content' do
          ol do
            startups_without_live_targets.limit(10).each do |startup|
              li do
                link_to startup.display_name, admin_startup_path(startup)
              end
            end
          end
        end

        div class: 'footer-spacer'

        div class: 'footer' do
          a href: admin_startups_path(scope: 'without_live_targets'), class: 'button view-all' do
            "View All (#{startups_without_live_targets.count})"
          end
        end
      end

      div class: 'dashboard-item' do
        startups_with_targets_completed_last_week = Startup.with_targets_completed_last_week.order('targets.completed_at DESC')

        div class: 'heading' do
          'Startups with Targets Completed Last Week'
        end

        div class: 'content' do
          ol do
            startups_with_targets_completed_last_week.limit(10).each do |startup|
              li do
                link_to startup.display_name, admin_startup_path(startup)
              end
            end
          end
        end

        div class: 'footer-spacer'

        div class: 'footer' do
          div class: 'left-of-button' do
            "Completed in the last 3 weeks: #{Startup.with_completed_targets.where('targets.completed_at > ?', 3.week.ago).count}"
          end

          a href: admin_startups_path(scope: 'with_targets_completed_last_week'), class: 'button view-all' do
            "View All (#{startups_with_targets_completed_last_week.count})"
          end
        end
      end

      div class: 'dashboard-item' do
        startup_feedback_from_last_week = StartupFeedback.where('created_at > ?', 1.week.ago).order('created_at DESC')

        div class: 'heading' do
          'Feedback Submitted Last Week'
        end

        div class: 'content' do
          ol do
            startup_feedback_from_last_week.limit(10).each do |startup_feedback|
              li do
                link_to "#{startup_feedback.faculty.name} - #{startup_feedback.startup.product_name}", admin_startup_feedback_path(startup_feedback)
              end
            end
          end
        end

        div class: 'footer-spacer'

        div class: 'footer' do
          div class: 'left-of-button' do
            "Submitted in last 3 weeks: #{StartupFeedback.where('created_at > ?', 3.weeks.ago).count}"
          end

          a href: admin_startup_feedback_index_path(q: { created_at_gteq: 1.week.ago.strftime('%Y-%m-%d') }), class: 'button view-all' do
            "View All (#{startup_feedback_from_last_week.count})"
          end
        end
      end

      div class: 'dashboard-item' do
        connect_requests_confirmed = ConnectRequest.confirmed.order('confirmed_at DESC')

        div class: 'heading' do
          'Connect Requests - Confirmed'
        end

        div class: 'content' do
          ol do
            connect_requests_confirmed.limit(10).each do |connect_request|
              li do
                link_to "#{connect_request.startup.product_name} - #{connect_request.faculty.name}", admin_connect_request_path(connect_request)
              end
            end
          end
        end

        div class: 'footer-spacer'

        div class: 'footer' do
          div class: 'left-of-button' do
            "Confirmed since 3 weeks ago: #{ConnectRequest.confirmed.where('confirmed_at > ?', 3.weeks.ago).count}"
          end

          a href: admin_connect_requests_path(scope: 'confirmed'), class: 'button view-all' do
            "View All (#{connect_requests_confirmed.count})"
          end
        end
      end

      div class: 'dashboard-item' do
        connect_requests_requested = ConnectRequest.requested

        div class: 'heading' do
          'Connect Requests - Requested'
        end

        div class: 'content' do
          ol do
            connect_requests_requested.limit(10).each do |connect_request|
              li do
                link_to "#{connect_request.startup.product_name} - #{connect_request.faculty.name}", admin_connect_request_path(connect_request)
              end
            end
          end
        end

        div class: 'footer-spacer'

        div class: 'footer' do
          div class: 'left-of-button' do
            "Requested since 3 weeks ago: #{ConnectRequest.requested.where('created_at > ?', 3.weeks.ago).count}"
          end

          a href: admin_connect_requests_path(scope: 'requested'), class: 'button view-all' do
            "View All (#{connect_requests_requested.count})"
          end
        end
      end
    end
  end
end
