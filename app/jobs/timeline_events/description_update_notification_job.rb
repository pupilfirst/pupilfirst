module TimelineEvents
  class DescriptionUpdateNotificationJob < ApplicationJob
    queue_as :default

    def perform(timeline_event, old_description)
      @timeline_event = timeline_event
      @old_description = old_description

      if diff.present?
        PublicSlack::MessageService.new.execute(message: heading, founder: @timeline_event.founder)

        PublicSlack::SendFileService.new(@timeline_event.founder, diff_without_newline_notice, 'diff', filename).execute
      end
    end

    def diff
      @diff ||= Diffy::Diff.new(@old_description, @timeline_event.description).to_s
    end

    def diff_without_newline_notice
      diff.split("\n").reject { |line| line =~ /No newline at end of file/ }.join("\n")
    end

    def filename
      "Updated #{@timeline_event.title}".parameterize + '.txt'
    end

    def heading
      I18n.t(
        'jobs.timeline_event.description_update_notification.heading',
        event_title: @timeline_event.title,
        event_url: @timeline_event.share_url
      )
    end
  end
end
