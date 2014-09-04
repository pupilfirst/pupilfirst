require 'spec_helper'

describe StartupsController do
  describe 'routing' do
    # it "routes to #index" do
    #   expect(:get => "/startups").to route_to("startups#index")
    # end

    # it "routes to #new" do
    #   expect(:get => "/startups/new").to route_to("startups#new")
    # end

    it 'routes to #show' do
      expect(:get => '/startups/1').to route_to('startups#show', id: '1')
    end

    # it "routes to #edit" do
    #   expect(:get => "/startups/1/edit").to route_to("startups#edit", :id => "1")
    # end

    # it "routes to #create" do
    #   expect(:post => "/startups").to route_to("startups#create")
    # end

    # it "routes to #update" do
    #   expect(:put => "/startups/1").to route_to("startups#update", :id => "1")
    # end
  end
end
