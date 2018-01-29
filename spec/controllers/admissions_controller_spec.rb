require 'rails_helper'

describe AdmissionsController do
  let(:level_0) { create :level, :zero }
  let(:level_0_targets) { create :target_group, level: level_0 }
  let!(:screening_target) { create :target, :admissions_screening, target_group: level_0_targets }
  let!(:tet_team_update) { create :timeline_event_type, :team_update }

  let(:founder) { create :founder }
  let(:startup) { create :startup, level: level_0 }

  let(:typeform_webhook_response) do
    {
      'event_id' => 'hQJi65uTRz',
      'event_type' => 'form_response',
      'form_response' => {
        'form_id' => 'pWmL9d',
        'token' => '4969bac7b56e83a82ad060f0ae57faed',
        'submitted_at' => '2017-07-13T10:00:32Z',
        'calculated' => {
          'score' => 42
        },
        'hidden' => {
          'user_id' => founder.user.id
        },
        'definition' => {
          'id' => 'pWmL9d',
          'title' => 'all_questions_test',
          'fields' => [
            {
              'id' => '36754465',
              'title' => '1. Short text',
              'type' => 'short_text'
            },
            {
              'id' => '36754478',
              'title' => '2. Long text',
              'type' => 'long_text'
            }
          ]
        },
        'answers' => [
          {
            'type' => 'text',
            'text' => 'Lorem ipsum dolor',
            'field' => {
              'id' => '36754465',
              'type' => 'short_text'
            }
          },
          {
            'type' => 'text',
            'text' => 'Lorem ipsum dolor',
            'field' => {
              'id' => '36754478',
              'type' => 'long_text'
            }
          }
        ]
      }
    }
  end

  describe 'GET screening_submit' do
    before do
      startup.founders << founder
      sign_in founder.user
    end

    it 'redirects to founder dashboard and updates the founder of screening completion ' do
      get :screening_submit
      expect(response).to redirect_to(dashboard_founder_path(from: 'screening_submit'))
    end
  end

  describe 'POST screening_submit_webhook' do
    before do
      startup.founders << founder
    end

    it 'verifies the screening target, updates founder screening_data and updates stage in intercom' do
      expected_founder_screening_data = {
        "score" => 42,
        "response" => [
          { "answer" => "Lorem ipsum dolor",
            "question" => "1. Short text" },
          { "answer" => "Lorem ipsum dolor",
            "question" => "2. Long text" }
        ]
      }
      expect(Intercom::LevelZeroStageUpdateJob).to receive(:perform_now).with(founder, 'Self Evaluation Completed')

      post :screening_submit_webhook, params: typeform_webhook_response, as: :json

      expect(screening_target.status(founder)).to eq(Target::STATUS_COMPLETE)
      founder.reload
      expect(founder.screening_data).to eq(expected_founder_screening_data)
    end
  end
end
