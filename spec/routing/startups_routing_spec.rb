require 'rails_helper'

describe StartupsController do
  describe 'routing' do
    it 'routes to #show' do
      expect(get: 'startups/1').to route_to('startups#show', id: '1')
    end
  end
end
