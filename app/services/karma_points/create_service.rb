module KarmaPoints
  # Creates karma points for founders/startups and sends notification to founders.
  class CreateService
    def initialize(source, points, activity_type: nil)
      @source = source
      @points = points
      @activity_type = activity_type
    end

    def execute
      karma_point = create_karma_point
      send_notification
      karma_point
    end

    private

    def create_karma_point
      KarmaPoint.create!(
        source: @source,
        founder: founder,
        startup: startup,
        activity_type: activity_type,
        points: @points
      )
    end

    def send_notification
      VocalistPingJob.perform_later(message, recipients)
    end

    def founder
      return nil if @source.is_a?(ConnectRequest)

      if @source.is_a?(PlatformFeedback) || @source.is_a?(PublicSlackMessage)
        @source.founder
      elsif @source.is_a?(TimelineEvent)
        @source.founder_event? ? @source.founder : nil
      end
    end

    def startup
      @startup = (@source.respond_to?(:startup) && @source.startup) || @source.founder.startup
    end

    def activity_type
      return @activity_type if @activity_type.present?

      if @source.is_a?(TimelineEvent)
        "Added a new Timeline event - #{@source.title}"
      elsif @source.is_a?(PlatformFeedback)
        "Submitted Platform Feedback on #{@source.created_at.strftime('%b %d, %Y')}"
      elsif @source.is_a?(ConnectRequest)
        "Connect session with faculty member #{@source.faculty.name}"
      end
    end

    def message
      if founder.present?
        I18n.t('services.karma_points.create.founder_slack_notification', message_params)
      else
        I18n.t('services.karma_points.create.startup_slack_notification', message_params)
      end
    end

    def message_params
      {
        startup_url: Rails.application.routes.url_helpers.timeline_url(startup.id, startup.slug),
        startup_product_name: startup.product_name,
        points: @points,
        activity_type: activity_type
      }
    end

    def recipients
      return { founders: startup.founders.pluck(:id) } if founder.blank?
      { founder: founder }
    end
  end
end
