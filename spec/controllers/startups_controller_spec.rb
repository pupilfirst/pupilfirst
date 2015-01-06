require 'spec_helper'

describe StartupsController do
  before(:each) { login_user }
  # This should return the minimal set of attributes required to create a valid
  # Startup. As you add validations to Startup, be sure to
  # adjust the attributes here as well.
  let(:valid_attributes) {
    attributes_for(:startup).merge(categories: [build(:startup_category)], founders: [build(:founder)])
  }
  let(:valid_params) {
    attributes_for(:startup).merge(category_ids: [create(:startup_category).id])
  }

  let(:valid_session) { {} }
  let(:startup) { startup = Startup.create! valid_attributes }

  describe "GET show" do
    it "assigns the requested startup as @startup" do
      @current_user.update_attributes(startup: startup)
      get :show, {:id => startup.to_param}, valid_session
      expect(assigns(:startup)).to eq(startup)
    end
  end

  # describe "GET new" do
  #   it "assigns a new startup as @startup" do
  #     get :new, {}, valid_session
  #     expect(assigns(:startup)).to be_a_new(Startup)
  #   end
  # end

  # describe "GET edit" do
  #   it "assigns the requested startup as @startup" do
  #     startup.founders << @current_user
  #     @current_user.update_attributes(startup: startup)
  #     get :edit, {:id => startup.to_param}, valid_session
  #     expect(assigns(:startup)).to eq(startup)
  #   end
  # end

  # describe "POST create" do
  #   describe "with valid params" do
  #     it "creates a new Startup" do
  #       expect {
  #         post :create, {:startup => valid_params}, valid_session
  #       }.to change(Startup, :count).by(1)
  #     end
  #
  #     it "assigns a newly created startup as @startup" do
  #       post :create, {:startup => valid_params}, valid_session
  #       expect(assigns(:startup)).to be_a(Startup)
  #       expect(assigns(:startup)).to be_persisted
  #     end
  #   end
  # end

  # describe "PUT update" do
  #   describe "with valid params" do
  #     it "updates the requested startup" do
  #       # Assuming there are no other startups in the database, this
  #       # specifies that the Startup created on the previous line
  #       # receives the :update_attributes message with whatever params are
  #       # submitted in the request.
  #       expect_any_instance_of(Startup).to receive(:update_attributes).with({ "name" => "MyString" })
  #       put :update, {:id => startup.to_param, :startup => { "name" => "MyString" }}, valid_session
  #     end
  #
  #     it "assigns the requested startup as @startup" do
  #       put :update, {:id => startup.to_param, :startup => valid_attributes}, valid_session
  #       expect(assigns(:startup)).to eq(startup)
  #     end
  #
  #     it "redirects to the startup" do
  #       put :update, {:id => startup.to_param, :startup => valid_attributes}, valid_session
  #       expect(response).to redirect_to(startup_founders_path(startup))
  #     end
  #   end
  #
  #   describe "with invalid params" do
  #     it "assigns the startup as @startup" do
  #       # Trigger the behavior that occurs when invalid params are submitted
  #       Startup.any_instance.stub(:save).and_return(false)
  #       put :update, {:id => startup.to_param, :startup => { "name" => nil }}, valid_session
  #       expect(assigns(:startup)).to eq(startup)
  #     end
  #
  #   end
  # end

  # describe "DELETE destroy" do
  #   it "destroys the requested startup" do
  #     startup = Startup.create! valid_attributes
  #     expect {
  #       delete :destroy, {:id => startup.to_param}, valid_session
  #     }.to change(Startup, :count).by(-1)
  #   end
  #
  #   it "redirects to the startups list" do
  #     delete :destroy, {:id => startup.to_param}, valid_session
  #     expect(response).to redirect_to(startups_url)
  #   end
  # end
end
