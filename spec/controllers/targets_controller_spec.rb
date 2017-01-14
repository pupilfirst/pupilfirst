require 'rails_helper'

describe TargetsController do
  include Devise::Test::ControllerHelpers

  let!(:startup) { create :startup }
  let!(:target) { create :target, :with_rubric, :with_program_week, batch: startup.batch }

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
end
