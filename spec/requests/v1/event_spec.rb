require "spec_helper"

describe "Event Requests" do
	include V1ApiSpecHelper

  it "fetch events on index" do
  	n = create(:event)
    get "/api/events", {},version_header
    expect(response).to render_template(:index)
		response.body.should have_json_path("0/id")
		response.body.should have_json_path("0/author/id")
    get "/api/events", {category: n.category.name},version_header
    expect(response).to render_template(:index)
		response.body.should have_json_path("0/id")
		response.body.should have_json_path("0/author/id")
  end

  it "fetches one event item with description" do
  	n = create(:event)
  	get "/api/events/#{n.id}", {}, version_header
    expect(response).to render_template(:show)
		response.body.should have_json_path("id")
		response.body.should have_json_path("description")
		response.body.should have_json_path("author/id")

  end
end
