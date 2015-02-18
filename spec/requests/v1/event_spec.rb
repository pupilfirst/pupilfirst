require "spec_helper"

describe "Event Requests" do
  include V1ApiSpecHelper

  it "fetch events on index" do
    n = create(:event, approved: true)
    get "/api/events", {},version_header
    expect(response).to render_template(:index)
    expect(response.body).to have_json_path("0/id")
    expect(response.body).to have_json_path("0/author/id")
    get "/api/events", {category: n.category.name},version_header
    expect(response).to render_template(:index)
    expect(response.body).to have_json_path("0/id")
    expect(response.body).to have_json_path("0/author/id")
  end

  it "fetches one event item with description" do
    n = create(:event)
    get "/api/events/#{n.id}", {}, version_header
    expect(response).to render_template(:show)
    expect(response.body).to have_json_path("id")
    expect(response.body).to have_json_path("description")
    expect(response.body).to have_json_path("author/id")

  end
end
