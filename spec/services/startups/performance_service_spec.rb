require 'rails_helper'

describe Startups::PerformanceService do
  subject { described_class.new }
  include ActiveSupport::Testing::TimeHelpers

  let!(:batch) { create :batch, :with_startups, start_date: 12.days.ago }

  POINTS_LAST_WEEK = [10, 200, 210, 210, 240, 280, 500, 1000].freeze
  POINTS_TWO_WEEKS_BACK = [100, 200, 300, 400].freeze

  before do
    # add some karma points for last week
    POINTS_LAST_WEEK.each.with_index(1) do |points, index|
      startup = batch.startups.order(:id).limit(index).last
      create :karma_point, created_at: 10.days.ago, startup: startup, points: points
    end

    # add some karma points for two weeks back
    POINTS_TWO_WEEKS_BACK.each.with_index(1) do |points, index|
      startup = batch.startups.order(:id).limit(index).last
      create :karma_point, created_at: 15.days.ago, startup: startup, points: points
    end
  end

  describe '#leaderboard' do
    it 'returns the leaderboard rank list from last week when invoked after Monday 6 p.m' do
      travel_to(Time.now.beginning_of_week + 20.hours) do
        expected_ranks = [8, 7, 5, 5, 4, 3, 2, 1, 9, 9]
        expected_leaderboard = batch.startups.order(:id).each_with_index.map do |startup, index|
          [startup, expected_ranks[index], POINTS_LAST_WEEK[index] || 0]
        end

        expect(subject.leaderboard(batch).sort).to eq(expected_leaderboard)
      end
    end

    it 'returns the leaderboard rank list from two weeks back when invoked before Monday 6 p.m' do
      travel_to(Time.now.beginning_of_week + 15.hours) do
        expected_ranks = [4, 3, 2, 1, 5, 5, 5, 5, 5, 5]
        expected_leaderboard = batch.startups.order(:id).each_with_index.map do |startup, index|
          [startup, expected_ranks[index], POINTS_TWO_WEEKS_BACK[index] || 0]
        end

        expect(subject.leaderboard(batch).sort).to eq(expected_leaderboard)
      end
    end
  end

  describe '#leaderboard_rank' do
    it 'returns the leaderboard rank of the specified startup' do
      expect(subject.leaderboard_rank(batch.startups.first)).to eq(8)
    end
  end

  describe '#last_week_karma' do
    it 'returns the karma points earned last week by the specified startup' do
      expect(subject.last_week_karma(batch.startups.second)).to eq(200)
      expect(subject.last_week_karma(batch.startups.last)).to eq(0)
    end
  end

  describe '#relative_performance' do
    it 'returns a relative measure of performance for the startup specified' do
      startups = batch.startups.order(:id)

      expect(subject.relative_performance(startups.first)).to eq(30)
      expect(subject.relative_performance(startups.fifth)).to eq(50)
      expect(subject.relative_performance(startups.limit(8).last)).to eq(90)
    end
  end
end
