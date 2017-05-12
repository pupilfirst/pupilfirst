require 'rails_helper'

require_relative '../../../lib/lita/handlers/leaderboard'

describe Lita::Handlers::Leaderboard do
  include ActiveSupport::Testing::TimeHelpers

  describe '#leaderboard' do
    let(:test_time) { Time.parse '2017-04-19 12:00:00 +0530' }
    let(:leaderboard_service) { instance_double Startups::LeaderboardService }
    let(:level_one) { create :level, :one }
    let(:startup_1) { build :startup }
    let(:startup_2) { build :startup }
    let(:startup_3) { build :startup }
    let(:startup_4) { build :startup }
    let(:startup_5) { build :startup }

    let(:leaderboard) do
      [
        [startup_1, 1, 100, 1],
        [startup_2, 2, 70, 0],
        [startup_3, 2, 70, -1],
        [startup_4, 4, 0, 1],
        [startup_5, 4, 0, -2]
      ]
    end

    before do
      allow(Startups::LeaderboardService).to receive(:new).with(level_one).and_return(leaderboard_service)
      allow(Startups::LeaderboardService).to receive(:pending?).and_return(false)
      allow(leaderboard_service).to receive(:leaderboard_with_change_in_rank).and_return(leaderboard)
    end

    context 'when no level number is specified' do
      let(:response) { double 'Lita Response Object', match_data: %w(leaderboard) }

      it 'requests user to supply level number' do
        expect(response).to receive(:reply).with('Please supply the level number for which leaderboard is required! Try `leaderboard [1-4]`')

        subject.leaderboard(response)
      end
    end

    context 'when level number is specified' do
      let(:response) { double 'Lita Response Object', match_data: %w(leaderboard 1) }

      it 'replies with leaderboard for requested level' do
        travel_to(test_time) do
          expected_response = <<~EXPECTED_RESPONSE.strip
            *<http://localhost:3000/about/leaderboard|Leaderboard for Level 1> - April 10 to April 17:*
            *01.* :rank_up:` +1` - <http://localhost:3000/startups/#{startup_1.slug}|#{startup_1.product_name}>
            *02.* :rank_nochange:`---` - <http://localhost:3000/startups/#{startup_2.slug}|#{startup_2.product_name}>
            *02.* :rank_down:` -1` - <http://localhost:3000/startups/#{startup_3.slug}|#{startup_3.product_name}>

            There are 2 startups in this level which were inactive during this period.
          EXPECTED_RESPONSE

          expect(response).to receive(:reply).with(expected_response)

          subject.leaderboard(response)
        end
      end

      context 'when there are active startups in requested level' do
        let(:leaderboard) do
          [
            [startup_1, 1, 0, 1],
            [startup_2, 1, 0, -1]
          ]
        end

        it 'replies that there are no active startups in the level' do
          expect(response).to receive(:reply).with('All startups at this level were inactive during this period.')
          subject.leaderboard(response)
        end
      end

      context 'when the leaderboard is empty' do
        let(:leaderboard) { [] }

        context 'when leaderboard has not been generated' do
          before do
            allow(Startups::LeaderboardService).to receive(:pending?).and_return(true)
          end

          it 'replies that the leaderboard is being generated' do
            expect(response).to receive(:reply).with('The leaderboard for last week is being generated. Please try again after a minute.')
            subject.leaderboard(response)
          end
        end

        context 'when the leaderboard has been generated' do
          it 'replies that there are no active startups in the level' do
            expect(response).to receive(:reply).with('All startups at this level were inactive during this period.')
            subject.leaderboard(response)
          end
        end
      end
    end
  end
end
