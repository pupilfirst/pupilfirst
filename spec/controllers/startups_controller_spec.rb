require 'rails_helper'

describe StartupsController do
  include ControllerMacros

  before(:each) { login_founder }

  # This should return the minimal set of attributes required to create a valid
  # Startup. As you add validations to Startup, be sure to
  # adjust the attributes here as well.
  let(:valid_attributes) do
    attributes_for(:startup).merge(startup_categories: [build(:startup_category)], founders: [build(:founder)])
  end

  let(:valid_params) { attributes_for(:startup).merge(startup_category_ids: [create(:startup_category).id]) }

  let(:valid_session) { {} }
  let(:startup) { Startup.create! valid_attributes }

  describe 'GET show' do
    it 'assigns the requested startup as @startup' do
      @current_founder.update_attributes(startup: startup)
      get :show, { id: startup.to_param }, valid_session
      expect(assigns(:startup)).to eq(startup)
    end
  end
end
