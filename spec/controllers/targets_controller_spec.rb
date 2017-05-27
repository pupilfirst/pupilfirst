require 'rails_helper'

describe TargetsController do
  include Devise::Test::ControllerHelpers

  let!(:startup) { create :startup }
  let!(:target) { create :target, :with_rubric }
  let!(:pending_prerequisite_target) { create :target }
  let!(:completed_prerequisite_target) { create :target }
  let!(:completion_event) do
    create :timeline_event,
      startup: startup, founder: startup.admin,
      target: completed_prerequisite_target,
      verified_status: TimelineEvent::VERIFIED_STATUS_VERIFIED
  end
  let!(:founder_target) { create :target, role: Target::ROLE_FOUNDER }
  let!(:completion_event_2) do
    create :timeline_event,
      startup: startup, founder: startup.admin,
      target: founder_target,
      verified_status: TimelineEvent::VERIFIED_STATUS_VERIFIED
  end

  let!(:faculty) { create :faculty }
  let!(:target_feedback) { create :startup_feedback, timeline_event: completion_event_2, faculty: faculty, startup: startup }

  describe 'GET download_rubric' do
    it 'raises not found error when a founder is not signed in' do
      expect do
        get :download_rubric, params: { id: target.id }
      end.to raise_error(ActionController::RoutingError)
    end

    it 'redirects to the rubric URL when a founder is signed in' do
      sign_in startup.admin.user
      get :download_rubric, params: { id: target.id }
      expect(response).to redirect_to(target.rubric_url)
    end
  end

  describe 'GET prerequisite_targets' do
    context 'founder is not signed in' do
      it 'raises not found error' do
        expect do
          get :prerequisite_targets, params: { id: target.id }
        end.to raise_error(ActionController::RoutingError)
      end
    end

    context 'when a founder is signed in' do
      before do
        sign_in startup.admin.user
      end

      context 'when target has no prerequisite targets' do
        it 'returns an empty hash' do
          get :prerequisite_targets, params: { id: target.id }
          expect(JSON.parse(response.body)).to eq({})
        end
      end

      context 'when target has prerequisite targets' do
        before do
          target.prerequisite_targets << [pending_prerequisite_target, completed_prerequisite_target]
        end
        it 'returns a hash of pending prerequisites with ids mapped to target title' do
          get :prerequisite_targets, params: { id: target.id }
          expect(JSON.parse(response.body)).to eq(pending_prerequisite_target.id.to_s => pending_prerequisite_target.title)
        end
      end
    end
  end

  describe 'GET founder_statuses' do
    it 'raises not found error when a founder is not signed in' do
      expect do
        get :founder_statuses, params: { id: target.id }
      end.to raise_error(ActionController::RoutingError)
    end

    it 'responds with the founder statuses when a founder is signed in' do
      sign_in startup.admin.user
      cofounder = startup.founders.where(startup_admin: nil).first
      statuses = [{ startup.admin.id.to_s => Target::STATUS_COMPLETE.to_s }, { cofounder.id.to_s => Target::STATUS_PENDING.to_s }]
      get :founder_statuses, params: { id: founder_target.id }
      expect(JSON.parse(response.body)).to match_array(statuses)
    end
  end

  describe 'GET startup_feedback' do
    before do
      sign_in startup.admin.user
    end

    context 'when target has no feedbacks' do
      it 'returns an empty hash' do
        get :startup_feedback, params: { id: completed_prerequisite_target.id }
        expect(JSON.parse(response.body)).to eq({})
      end
    end

    context 'when target has feedbacks' do
      it 'returns a hash of startup feedbacks with ids mapped to the feedback' do
        expected_response = { target_feedback.id.to_s => target_feedback.feedback.to_s }
        get :startup_feedback, params: { id: founder_target.id }
        expect(JSON.parse(response.body)).to eq(expected_response)
      end
    end
  end
end
