require 'rails_helper'

describe KarmaPoints::CreateService do
  subject { described_class }

  describe '#execute' do
    let!(:startup) { create :startup }
    let!(:founder) { create :founder, startup: startup }
    let!(:timeline_event_type_founder) { create :timeline_event_type, role: TimelineEventType::ROLE_FOUNDER }
    let!(:timeline_event_type_startup) { create :timeline_event_type, role: TimelineEventType::ROLE_DESIGN }
    let!(:timeline_event_for_founder_target) { create :timeline_event, founder: founder, startup: startup, timeline_event_type: timeline_event_type_founder }
    let!(:timeline_event_for_startup_target) { create :timeline_event, startup: startup, timeline_event_type: timeline_event_type_startup }
    let(:connect_request) { create :connect_request, startup: startup }
    let(:platform_feedback) { create :platform_feedback, founder: founder }
    let(:public_slack_message) { create :public_slack_message, founder: founder }
    let(:activity_type) { Faker::Lorem.sentence }

    let(:founder_message_for_founder_target) do
      I18n.t(
        'services.karma_points.create.founder_slack_notification',
        points: 10,
        activity_type: "Added a new Timeline event - #{timeline_event_for_founder_target.title}"
      )
    end

    let(:founder_message_for_slack_activity) do
      I18n.t(
        'services.karma_points.create.founder_slack_notification',
        points: 20,
        activity_type: activity_type
      )
    end

    let(:founder_message_for_platform_feedback) do
      I18n.t(
        'services.karma_points.create.founder_slack_notification',
        points: 30,
        activity_type: "Submitted Platform Feedback on #{platform_feedback.created_at.strftime('%b %d, %Y')}"
      )
    end

    let(:team_message_for_startup_target) do
      I18n.t(
        'services.karma_points.create.startup_slack_notification',
        points: 40,
        activity_type: "Added a new Timeline event - #{timeline_event_for_startup_target.title}",
        startup_url: Rails.application.routes.url_helpers.timeline_url(startup.id, startup.slug),
        startup_product_name: startup.product_name
      )
    end

    let(:team_message_for_connect_request) do
      I18n.t(
        'services.karma_points.create.startup_slack_notification',
        points: 50,
        activity_type: "Connect session with faculty member #{connect_request.faculty.name}",
        startup_url: Rails.application.routes.url_helpers.timeline_url(startup.id, startup.slug),
        startup_product_name: startup.product_name
      )
    end

    it 'creates karma points for verified founder targets and sends slack notification' do
      expect(VocalistPingJob).to receive(:perform_later).with(founder_message_for_founder_target, founder: founder)
      expect { subject.new(timeline_event_for_founder_target, 10).execute }.to change { KarmaPoint.count }.by(1)
      last_karma_point = KarmaPoint.last

      expect(last_karma_point.source).to eq(timeline_event_for_founder_target)
      expect(last_karma_point.founder).to eq(founder)
      expect(last_karma_point.startup).to eq(startup)
    end

    it 'creates karma points for founder activity in public slack and sends sends slack notification' do
      expect(VocalistPingJob).to receive(:perform_later).with(founder_message_for_slack_activity, founder: founder)
      expect { subject.new(public_slack_message, 20, activity_type: activity_type).execute }.to change { KarmaPoint.count }.by(1)
      last_karma_point = KarmaPoint.last

      expect(last_karma_point.source).to eq(public_slack_message)
      expect(last_karma_point.founder).to eq(founder)
      expect(last_karma_point.startup).to eq(startup)
    end

    it 'creates karma points for founder giving a platform feedback and sends slack notification' do
      expect(VocalistPingJob).to receive(:perform_later).with(founder_message_for_platform_feedback, founder: founder)
      expect { subject.new(platform_feedback, 30).execute }.to change { KarmaPoint.count }.by(1)
      last_karma_point = KarmaPoint.last

      expect(last_karma_point.source).to eq(platform_feedback)
      expect(last_karma_point.founder).to eq(founder)
      expect(last_karma_point.startup).to eq(startup)
    end

    it 'creates karma points for verified startup target and sends slack notification to all founders' do
      expect(VocalistPingJob).to receive(:perform_later).with(team_message_for_startup_target, founders: startup.founders.pluck(:id))
      expect { subject.new(timeline_event_for_startup_target, 40).execute }.to change { KarmaPoint.count }.by(1)
      last_karma_point = KarmaPoint.last

      expect(last_karma_point.source).to eq(timeline_event_for_startup_target)
      expect(last_karma_point.founder).to eq(nil)
      expect(last_karma_point.startup).to eq(startup)
    end

    it 'creates karma points for faculty connect request and sends slack notification to all founders' do
      expect(VocalistPingJob).to receive(:perform_later).with(team_message_for_connect_request, founders: startup.founders.pluck(:id))
      expect { subject.new(connect_request, 50).execute }.to change { KarmaPoint.count }.by(1)
      last_karma_point = KarmaPoint.last

      expect(last_karma_point.source).to eq(connect_request)
      expect(last_karma_point.founder).to eq(nil)
      expect(last_karma_point.startup).to eq(startup)
    end
  end
end
