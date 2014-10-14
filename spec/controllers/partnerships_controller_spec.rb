require 'spec_helper'

describe PartnershipsController do

  describe "GET 'confirm'" do
    it "returns http success" do
      get 'confirm'
      response.should be_success
    end
  end

end
