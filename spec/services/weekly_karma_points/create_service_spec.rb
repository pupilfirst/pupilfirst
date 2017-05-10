require 'rails_helper'

describe WeeklyKarmaPoints::CreateService do
  include ActiveSupport::Testing::TimeHelpers

  subject { described_class }

  let(:l1_startup_1) { create :startup }
  let(:l1_startup_2) { create :startup }
  let(:level_one) { create :level, :one }
  let(:level_two) { create :level, :two }
  let(:l2_startup_1) { create :startup, level: level_two }
  let(:l2_startup_2) { create :startup, level: level_two }
  let(:test_time) { Time.parse('2017-04-24 18:01:00 +0530') }

  before do
    travel_to(test_time) do
      # Create last week's karma points.
      create :karma_point, founder: l1_startup_1.admin, points: 100, created_at: 6.days.ago
      create :karma_point, founder: l1_startup_2.admin, points: 50, created_at: 6.days.ago
      create :karma_point, founder: l1_startup_2.admin, points: 25, created_at: 5.days.ago
      create :karma_point, founder: l2_startup_1.admin, points: 80, created_at: 6.days.ago
      create :karma_point, founder: l2_startup_2.admin, points: 50, created_at: 6.days.ago
      create :karma_point, founder: l2_startup_2.admin, points: 40, created_at: 5.days.ago

      # Create karma points for two weeks ago.
      create :karma_point, founder: l1_startup_1.admin, points: 70, created_at: 13.days.ago
      create :karma_point, founder: l1_startup_2.admin, points: 40, created_at: 13.days.ago
      create :karma_point, founder: l1_startup_2.admin, points: 35, created_at: 12.days.ago
      create :karma_point, founder: l2_startup_1.admin, points: 50, created_at: 12.days.ago
      create :karma_point, founder: l2_startup_1.admin, points: 50, created_at: 11.days.ago
      create :karma_point, founder: l2_startup_2.admin, points: 60, created_at: 10.days.ago
    end
  end

  describe '#execute' do
    it 'creates weekly karma points for last week' do
      travel_to(test_time) do
        described_class.new.execute
        expect(WeeklyKarmaPoint.count).to eq(4)

        result = WeeklyKarmaPoint.order(week_starting_at: :desc, points: :desc)
          .pluck(:startup_id, :level_id, :week_starting_at, :points)

        last_week_start = 7.days.ago.beginning_of_week + 18.hours

        expected_result = [
          [l1_startup_1.id, level_one.id, last_week_start, 100],
          [l2_startup_2.id, level_two.id, last_week_start, 90],
          [l2_startup_1.id, level_two.id, last_week_start, 80],
          [l1_startup_2.id, level_one.id, last_week_start, 75]
        ]

        expect(result).to eq(expected_result)
      end
    end

    context 'when supplied with a week_at' do
      it 'creates weekly karma points for the week containing the supplied time' do
        travel_to(test_time) do
          time_from_two_weeks_ago = Time.parse('2017-04-12 00:00:00 +0530')

          described_class.new(week_at: time_from_two_weeks_ago).execute
          expect(WeeklyKarmaPoint.count).to eq(4)

          result = WeeklyKarmaPoint.order(week_starting_at: :desc, points: :desc)
            .pluck(:startup_id, :level_id, :week_starting_at, :points)

          two_weeks_ago_start = 14.days.ago.beginning_of_week + 18.hours

          expected_result = [
            [l2_startup_1.id, level_two.id, two_weeks_ago_start, 100],
            [l1_startup_2.id, level_one.id, two_weeks_ago_start, 75],
            [l1_startup_1.id, level_one.id, two_weeks_ago_start, 70],
            [l2_startup_2.id, level_two.id, two_weeks_ago_start, 60]
          ]

          expect(result).to eq(expected_result)
        end
      end
    end
  end
end
