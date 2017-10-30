require 'rails_helper'

describe StartupsController do
  describe 'GET /:id' do
    it 'routes to #show' do
      expect(get: 'startups/1').to route_to('startups#show', id: '1')
    end
  end

  describe 'GET /:id/:event_title/:event_id' do
    let(:timeline_event) { create :timeline_event, :verified }
    render_views

    it 'routes to #timeline_event_show' do
      expect(get: 'startups/1/some_title/2').to route_to('startups#timeline_event_show', id: '1', event_title: 'some_title', event_id: '2')
    end

    it 'populates the correct meta tags' do
      og_title = "#{timeline_event.title} from #{timeline_event.startup.product_name}"
      title_tag = "meta[property=\"og:title\"][content=\"#{og_title}\"]"

      get :timeline_event_show, params: { id: timeline_event.startup.id, event_title: 'some_title', event_id: timeline_event.id }
      expect(response.body).to have_css(title_tag, visible: false)
    end
  end
end
