require 'rails_helper'

describe Admin::CoreStatsService do
  subject { described_class.new }

  # A couple of admitted (Level 1) startups with 2 founders each.
  let(:admitted_startups) { create_list :startup, 2 }

  # Setup the required data:
  before do
    # Add a few platform feedback to check NPS.
    founder = admitted_startups.first.founders.first
    create :platform_feedback, founder: founder, created_at: 1.day.ago, promoter_score: 9
    create :platform_feedback, founder: founder, created_at: 2.days.ago, promoter_score: 3 # this score must be ignored
    create :platform_feedback, founder: admitted_startups.first.founders.second, promoter_score: 10
    create :platform_feedback, founder: admitted_startups.second.founders.first, promoter_score: 10
    create :platform_feedback, founder: admitted_startups.second.founders.second, promoter_score: 2

    # One founder was active on Slack yesterday and on web last week.
    create :public_slack_message, founder: founder, created_at: 1.day.ago
    create :visit, user: founder.user, started_at: 4.days.ago

    # A second founder was active on Slack last week and on web last month.
    founder = admitted_startups.first.founders.second
    create :public_slack_message, founder: founder, created_at: 5.days.ago
    create :visit, user: founder.user, started_at: 20.days.ago

    # Another founder was active on Slack last month and never on web.
    founder = admitted_startups.second.founders.first
    create :public_slack_message, founder: founder, created_at: 20.days.ago
    # And the fourth founder was never active!
  end

  describe '#stats' do
    it 'returns a hash containing all core stats' do
      expect(subject.stats).to eq(expected_stats)
    end
  end

  def expected_stats
    {
      nps: 50.0,
      nps_count: 4,
      slack: expected_slack_stats,
      web: expected_web_stats,
      total: expected_total_stats
    }
  end

  def expected_slack_stats
    {
      dau: 1,
      percentage_dau: 25.0,
      wau: 2,
      percentage_wau: 50.0,
      mau: 3,
      percentage_mau: 75.0,
      wau_trend: [0, 0, 0, 0, 0, 1, 0, 2]
    }
  end

  def expected_web_stats
    {
      dau: 0,
      percentage_dau: 0.0,
      wau: 1,
      percentage_wau: 25.0,
      mau: 2,
      percentage_mau: 50.0,
      wau_trend: [0, 0, 0, 0, 0, 1, 0, 1]
    }
  end

  def expected_total_stats
    {
      dau: 1,
      percentage_dau: 25.0,
      wau: 2,
      percentage_wau: 50.0,
      mau: 3,
      percentage_mau: 75.0,
      wau_trend: [0, 0, 0, 0, 0, 2, 0, 2]
    }
  end
end
