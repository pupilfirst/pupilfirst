require 'rails_helper'

describe TimelineEvents::VerificationNotificationJob, broken: true do
  subject { described_class }

  let!(:startup) { create :startup }
  let!(:founder) { create :founder, startup: startup }
  let!(:founder_target) { create :target, role: Target::ROLE_STUDENT }
  let!(:startup_target) { create :target, role: Target::ROLE_TEAM }
  let!(:timeline_event_for_founder) { create :timeline_event, founder: founder, startup: startup, target: founder_target, status: "Verified" }
  let!(:timeline_event_for_startup) { create :timeline_event_with_links, founder: founder, startup: startup, target: startup_target, status: "Verified" }
  let(:startup_url) { Rails.application.routes.url_helpers.product_url(startup.id, startup.slug) }

  let(:links_attached_notice) do
    notice = "*Public Links attached:*\n"
    timeline_event_for_startup.links.each.with_index(1) do |link, index|
      next if link[:private]

      shortened_url = ShortenedUrls::ShortenService.new(link[:url]).shortened_url
      notice += "#{index}. <https://sv.co/r/#{shortened_url.unique_key}|#{link[:title]}>\n"
    end
    notice
  end

  let(:expected_founder_message_for_founder_target) do
    I18n.t(
      'jobs.timeline_events.verification_notification.founder.verified.founder_event',
      event_title: timeline_event_for_founder.title,
      startup_url: startup_url,
      event_url: timeline_event_for_founder.share_url
    )
  end

  let(:expected_founder_message_for_startup_target) do
    I18n.t(
      'jobs.timeline_events.verification_notification.founder.verified.startup_event',
      event_title: timeline_event_for_startup.title,
      startup_url: startup_url,
      event_url: timeline_event_for_startup.share_url,
      startup_name: startup.name
    )
  end

  let(:expected_team_message) do
    I18n.t(
      'jobs.timeline_events.verification_notification.team.verified',
      event_title: timeline_event_for_startup.title,
      event_url: timeline_event_for_startup.share_url,
      startup_url: startup_url,
      startup_name: startup.name
    )
  end

  let(:expected_public_message) do
    I18n.t(
      'jobs.timeline_events.verification_notification.public.verified',
      startup_url: startup_url,
      startup_name: startup.name,
      event_url: timeline_event_for_startup.share_url,
      event_title: timeline_event_for_startup.title,
      event_description: timeline_event_for_startup.description,
      links_attached_notice: links_attached_notice
    )
  end

  let(:mock_message_service) { instance_double PublicSlack::MessageService }

  describe '#perform' do
    it 'sends slack notification to the founder who created the timeline event for verified founder target' do
      expect(PublicSlack::MessageService).to receive(:new).and_return(mock_message_service)
      expect(mock_message_service).to receive(:post).with(message: expected_founder_message_for_founder_target, founder: timeline_event_for_founder.founder)
      subject.perform_now(timeline_event_for_founder)
    end

    it 'sends slack notification to the founder who submitted, to other team members and the public slack channel for verified startup target' do
      expect(PublicSlack::MessageService).to receive(:new).and_return(mock_message_service)
      expect(mock_message_service).to receive(:post).with(message: expected_founder_message_for_startup_target, founder: timeline_event_for_startup.founder)
      expect(mock_message_service).to receive(:post).with(message: expected_team_message, founders: (timeline_event_for_startup.startup&.founders || []) - [timeline_event_for_startup.founder])
      expect(mock_message_service).to receive(:post).with(message: expected_public_message, channel: TimelineEvents::VerificationNotificationJob::SLACK_CHANNEL)
      subject.perform_now(timeline_event_for_startup)
    end
  end
end
