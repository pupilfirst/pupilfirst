require 'rails_helper'

describe AdmissionStatsService, broken: true do
  subject { described_class }

  let(:round_1) { create :application_round, :screening_stage }
  let(:round_2) { create :application_round, :video_stage }
  let(:kerala_state) { create :state, name: 'Kerala' }
  let(:gujarat_state) { create :state, name: 'Gujarat' }
  let(:kerala_college_1) { create :college, state: kerala_state }
  let(:kerala_college_2) { create :college, state: kerala_state }
  let(:gujarat_college) { create :college, state: gujarat_state }

  let(:expected_overall_stats) do
    {
      total_applications: 10,
      total_applicants: 30,
      total_universities: 3,
      total_states: 2,
      paid_applications: 5,
      paid_from_earlier_rounds: nil,
      paid_applications_today: 4,
      payment_initiated: 2,
      payment_initiated_today: 2,
      submitted_applications: 3,
      submitted_applications_today: 3,
      top_references_today: [["Other", 9], ["Facebook", 1]],
      state_wise_stats:
        {
          Kerala:
          {
            paid_applications: 5,
            paid_applications_today: 4,
            payment_initiated: 2,
            payment_initiated_today: 2,
            submitted_applications: 0,
            submitted_applications_today: 0,
            conversion_percentage: 71.42857142857143
          }
        }
    }
  end

  let(:expected_round_1_stats) do
    {
      total_applications: 8,
      total_applicants: 24,
      total_universities: 3,
      total_states: 2,
      total_visits: 0,
      total_visits_today: 0,
      paid_applications: 3,
      paid_from_earlier_rounds: 1,
      paid_applications_today: 2,
      payment_initiated: 2,
      payment_initiated_today: 2,
      submitted_applications: 3,
      submitted_applications_today: 3,
      top_references_today: [["Other", 9], ["Facebook", 1]],
      state_wise_stats:
        {
          Kerala:
          {
            paid_applications: 3,
            paid_applications_today: 2,
            payment_initiated: 2,
            payment_initiated_today: 2,
            submitted_applications: 0,
            submitted_applications_today: 0,
            conversion_percentage: 60.0
          },
          Gujarat:
            {
              paid_applications: 0,
              paid_applications_today: 0,
              payment_initiated: 0,
              payment_initiated_today: 0,
              submitted_applications: 3,
              submitted_applications_today: 3,
              conversion_percentage: 0.0
            },
          Others:
            {
              paid_applications: 0,
              paid_applications_today: 0,
              payment_initiated: 0,
              payment_initiated_today: 0,
              submitted_applications: 0,
              submitted_applications_today: 0,
              conversion_percentage: 0
            }
        }
    }
  end

  before do
    # create a whole bunch of different applications in round 1
    create_list(:batch_application, 2, :payment_requested, college: kerala_college_1, application_round: round_1, team_size: 2)
    old_application = create(:batch_application, college: kerala_college_1, application_round: round_1, swept_in_at: 1.week.ago, team_size: 2)
    create(:payment, batch_application: old_application, paid_at: 3.weeks.ago)
    create_list(:batch_application, 2, :paid, college: kerala_college_2, application_round: round_1, team_size: 3)
    create_list(:batch_application, 3, college: gujarat_college, application_round: round_1, team_size: 4)
    BatchApplication.last.team_lead.update!(reference: 'Facebook')

    # create a couple of applications in round 2
    create_list(:batch_application, 2, :paid, college: kerala_college_2, application_round: round_2, team_size: 3)
  end

  describe '#load_overall_stats' do
    it 'returns the stats for all application rounds opened for admissions' do
      stats = subject.load_overall_stats
      expect(stats.deep_merge(expected_overall_stats)).to eq(stats)
    end
  end

  describe '#load_stats' do
    it 'returns the admission stats for the specified application round' do
      stats = subject.load_stats(round_1)
      expect(stats.deep_merge(expected_round_1_stats)).to eq(stats)
    end
  end
end
