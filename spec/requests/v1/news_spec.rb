require "spec_helper"

describe "News Requests" do
  include V1ApiSpecHelper

  it "fetch news on index" do
    n = create(:news, youtube_id: 'foo')
    get "/api/news", {},version_header
    expect(response).to render_template(:index)
    response.body.should have_json_path("0/id")
    response.body.should have_json_path("0/author/id")
    get "/api/news", {category: n.category.name},version_header
    expect(response).to render_template(:index)
    response.body.should have_json_path("0/id")
    response.body.should have_json_path("0/author/id")
  end

  it "fetches one news item with body" do
    n = create(:news, youtube_id: 'foo')
    get "/api/news/#{n.id}", {}, version_header
    expect(response).to render_template(:show)
    response.body.should have_json_path("id")
    response.body.should have_json_path("body")
    response.body.should have_json_path("author/id")

  end
end
