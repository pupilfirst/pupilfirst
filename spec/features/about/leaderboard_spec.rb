require 'rails_helper'

feature 'Leaderboard' do
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

    scenario 'user visits leaderboard page' do
      travel_to(test_time) do
        visit about_leaderboard_path

        expect(page).to have_content('Leaderboard April 10 to April 17')
        expect(page).to have_link(startup_1.display_name)
        expect(page).to have_link(startup_2.display_name)
        expect(page).to have_link(startup_3.display_name)
        expect(page).to have_content('There are 2 startups in this level which were inactive from April 10 to April 17.')
      end
    end

    context 'when there are active startups in requested level' do
      let(:leaderboard) do
        [
          [startup_1, 1, 0, 1],
          [startup_2, 1, 0, -1]
        ]
      end

      scenario 'user is shown that there are no active startups' do
        visit about_leaderboard_path
        expect(page).to have_content('All startups at this level were inactive during this period.')
      end
    end

    context 'when the leaderboard for last week has not been generated' do
      let(:leaderboard) { [] }

      before do
        allow(Startups::LeaderboardService).to receive(:pending?).and_return(true)
      end

      it 'asks the user to wait for leaderboard to be generated' do
        visit about_leaderboard_path
        expect(page).to have_content('Please wait while the leaderboard for the last week is generated.')
      end
    end
  end
end
