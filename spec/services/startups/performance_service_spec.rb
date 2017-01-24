require 'rails_helper'

describe Startups::PerformanceService do
  subject { described_class.new }
  include ActiveSupport::Testing::TimeHelpers

  let!(:batch) { create :batch, :with_startups, start_date: 12.days.ago }

  POINTS_LAST_WEEK = [10, 200, 210, 210, 240, 280, 500, 1000].freeze
  POINTS_TWO_WEEKS_BACK = [100, 200, 300, 400].freeze

  before do
    last_week = Time.zone.now.beginning_of_week - 3.days

    # add some karma points for last week
    POINTS_LAST_WEEK.each.with_index(1) do |points, index|
      startup = batch.startups.order(:id).limit(index).last
      create :karma_point, created_at: last_week, startup: startup, points: points
    end

    # calculate last weeks leaderboard
    ranks_last_week = [8, 7, 5, 5, 4, 3, 2, 1, 9, 9]
    @leaderboard_last_week = batch.startups.order(:id).each_with_index.map do |startup, index|
      [startup, ranks_last_week[index], POINTS_LAST_WEEK[index] || 0]
    end

    two_weeks_ago = Time.zone.now.beginning_of_week - 10.days

    # add some karma points for two weeks back
    POINTS_TWO_WEEKS_BACK.each.with_index(1) do |points, index|
      startup = batch.startups.order(:id).limit(index).last
      create :karma_point, created_at: two_weeks_ago, startup: startup, points: points
    end

    # calculate leaderboard two weeks back
    ranks_two_weeks_back = [4, 3, 2, 1, 5, 5, 5, 5, 5, 5]
    @leaderboard_two_week_back = batch.startups.order(:id).each_with_index.map do |startup, index|
      [startup, ranks_two_weeks_back[index], POINTS_TWO_WEEKS_BACK[index] || 0]
    end
  end

  describe '#leaderboard' do
    it 'returns the correct leaderboard when invoked throughout a day' do
      (0..24).each do |hour|
        travel_to(Time.zone.now.beginning_of_week + hour.hours) do
          if hour >= 18
            expect(subject.leaderboard(batch).sort).to eq(@leaderboard_last_week)
          else
            expect(subject.leaderboard(batch).sort).to eq(@leaderboard_two_week_back)
          end
        end
      end
    end
  end

  describe '#leaderboard_rank' do
    it 'returns the leaderboard rank of the specified startup' do
      travel_to(Time.zone.now.beginning_of_week) do
        expect(subject.leaderboard_rank(batch.startups.first)).to eq(4)
      end

      travel_to(Time.zone.now.end_of_week - 1.hour) do
        expect(subject.leaderboard_rank(batch.startups.first)).to eq(8)
      end
    end
  end

  describe '#last_week_karma' do
    it 'returns the karma points earned last week by the specified startup' do
      travel_to(Time.zone.now.beginning_of_week) do
        expect(subject.last_week_karma(batch.startups.first)).to eq(100)
        expect(subject.last_week_karma(batch.startups.last)).to eq(0)
      end

      travel_to(Time.zone.now.end_of_week - 1.hour) do
        expect(subject.last_week_karma(batch.startups.first)).to eq(10)
        expect(subject.last_week_karma(batch.startups.last)).to eq(0)
      end
    end
  end

  describe '#relative_performance' do
    it 'returns a relative measure of performance for the startup specified' do
      startups = batch.startups.order(:id)

      travel_to(Time.zone.now.end_of_week - 1.hour) do
        expect(subject.relative_performance(startups.first)).to eq(30)
        expect(subject.relative_performance(startups.fifth)).to eq(50)
        expect(subject.relative_performance(startups.limit(8).last)).to eq(90)
      end
    end
  end
end
