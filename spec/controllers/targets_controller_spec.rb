require 'rails_helper'

describe TargetsController do
  include Devise::Test::ControllerHelpers

  let!(:startup) { create :startup }
  let!(:target) { create :target, :with_rubric }
  let!(:prerequisite_target) { create :target }

  describe 'GET download_rubric' do
    context 'when user is not logged in' do
      it 'raises not found error' do
        expect do
          get :download_rubric, params: { id: target.id }
        end.to raise_error(ActionController::RoutingError)
      end
    end

    context "when the user is a founder in target's batch" do
      before do
        sign_in startup.admin.user
      end

      it 'redirects to the rubric URL' do
        get :download_rubric, params: { id: target.id }
        expect(response).to redirect_to(target.rubric_url)
      end
    end
  end

  describe 'GET prerequisite_targets' do
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
        target.prerequisite_targets << prerequisite_target
      end
      it 'returns a hash with ids mapped to target title' do
        get :prerequisite_targets, params: { id: target.id }
        expect(JSON.parse(response.body)).to eq(prerequisite_target.id.to_s => prerequisite_target.title)
      end
    end
  end
end
