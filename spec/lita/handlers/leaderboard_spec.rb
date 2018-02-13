require 'rails_helper'

require_relative '../../../lib/lita/handlers/leaderboard'

describe Lita::Handlers::Leaderboard do
  include ActiveSupport::Testing::TimeHelpers

  describe '#leaderboard' do
    let(:test_time) { Time.parse '2017-04-19 12:00:00 +0530' }
    let(:leaderboard_service_l1) { instance_double(Startups::LeaderboardService, leaderboard_with_change_in_rank: leaderboard_level_one) }
    let(:leaderboard_service_l2) { instance_double(Startups::LeaderboardService, leaderboard_with_change_in_rank: leaderboard_level_two) }
    let(:leaderboard_service_l3) { instance_double(Startups::LeaderboardService, leaderboard_with_change_in_rank: leaderboard_level_three) }
    let(:level_one) { create :level, :one }
    let(:level_two) { create :level, :two }
    let(:level_three) { create :level, :three }
    let!(:startup_1) { create :startup, level: level_one }
    let!(:startup_2) { create :startup, level: level_one }
    let!(:startup_3) { create :startup, level: level_one }
    let!(:startup_4) { create :startup, level: level_two }
    let!(:startup_5) { create :startup, level: level_two }
    let!(:startup_6) { create :startup, level: level_two }
    let!(:startup_7) { create :startup, level: level_three }

    let(:leaderboard_level_one) do
      [
        [startup_1, 1, 100, 1],
        [startup_2, 2, 70, 0],
        [startup_3, 2, 70, -1]
      ]
    end

    let(:leaderboard_level_two) do
      [
        [startup_4, 1, 100, 1],
        [startup_5, 2, 70, 0],
        [startup_6, 2, 0, -1]
      ]
    end

    let(:leaderboard_level_three) do
      [
        [startup_7, 1, 0, 0]
      ]
    end

    let!(:response) { double 'Lita Response Object', match_data: %w[leaderboard] }

    before do
      allow(Startups::LeaderboardService).to receive(:pending?).and_return(false)
      allow(Startups::LeaderboardService).to receive(:new).with(level_one).and_return(leaderboard_service_l1)
      allow(Startups::LeaderboardService).to receive(:new).with(level_two).and_return(leaderboard_service_l2)
      allow(Startups::LeaderboardService).to receive(:new).with(level_three).and_return(leaderboard_service_l3)
    end

    context 'when leaderboard is generated' do
      it 'replies with leaderboard for all levels' do
        travel_to(test_time) do
          expected_response = <<~EXPECTED_RESPONSE.strip
            *<http://localhost:3000/about/leaderboard|Leaderboards> - April 10 to April 17:*

            *Level 1:*
            *01.* :rank_up:` +1` - <http://localhost:3000/startups/#{startup_1.id}/#{startup_1.slug}|#{startup_1.product_name}>
            *02.* :rank_nochange:`---` - <http://localhost:3000/startups/#{startup_2.id}/#{startup_2.slug}|#{startup_2.product_name}>
            *02.* :rank_down:` -1` - <http://localhost:3000/startups/#{startup_3.id}/#{startup_3.slug}|#{startup_3.product_name}>


            *Level 2:*
            *01.* :rank_up:` +1` - <http://localhost:3000/startups/#{startup_4.id}/#{startup_4.slug}|#{startup_4.product_name}>
            *02.* :rank_nochange:`---` - <http://localhost:3000/startups/#{startup_5.id}/#{startup_5.slug}|#{startup_5.product_name}>
            There is 1 team in this level which was inactive during this period.

            All teams in *Level 3* were inactive during this period.
          EXPECTED_RESPONSE

          expect(response).to receive(:reply).with(expected_response)

          subject.leaderboard(response)
        end
      end
    end

    context 'when leaderboard has not been generated' do
      before do
        allow(Startups::LeaderboardService).to receive(:pending?).and_return(true)
      end

      it 'replies that the leaderboard is being generated' do
        expect(response).to receive(:reply).with('The leaderboard for last week is being generated. Please try again after a minute.')
        subject.leaderboard(response)
      end
    end
  end
end
