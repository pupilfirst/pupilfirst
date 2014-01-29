require "spec_helper"

describe "Startup Requests" do
	include V1ApiSpecHelper

  it "fetch startups on index" do
  	startup = create(:startup)
    get "/api/startups", {},version_header
    expect(response).to render_template(:index)
    response.body.should have_json_path("0/id")
    response.body.should have_json_path("0/name")
    response.body.should have_json_path("0/logo_url")
    response.body.should have_json_path("0/pitch")
    response.body.should have_json_path("0/website")
    response.body.should have_json_path("0/created_at")
  end

  it "fetch startups within a category" do
    startup1 = create(:startup)
    startup2 = create(:startup)
    get "/api/startups", {category: startup1.categories.first.name},version_header
    expect(response).to render_template(:index)
    response.body.should have_json_size(1).at_path("/")
    response.body.should have_json_path("0/id")
    response.body.should have_json_path("0/name")
    response.body.should have_json_path("0/logo_url")
    response.body.should have_json_path("0/pitch")
    response.body.should have_json_path("0/website")
    response.body.should have_json_path("0/created_at")
  end

  it "fetches related startups when searched for" do
    startup = create(:startup, {name: 'startup 1'})
    startup = create(:startup, {name: 'startup 2'})
    startup = create(:startup, {name: 'foobar 2'})
    startup = create(:startup, {name: 'foobar 1'})
    get "/api/startups", {search_term: 'foobar'}, version_header
    expect(response).to render_template(:index)
    response.body.should have_json_size(2).at_path("/")
    response.body.should have_json_path("0/id")
    response.body.should have_json_path("0/name")
    response.body.should have_json_path("0/logo_url")
    response.body.should have_json_path("0/pitch")
    response.body.should have_json_path("0/website")
    response.body.should have_json_path("0/created_at")
  end

  it "fetches one startup with " do
  	startup = create(:startup)
  	get "/api/startups/#{startup.id}", {}, version_header
    expect(response).to render_template(:show)
    response.body.should have_json_path("id")
    response.body.should have_json_path("name")
    response.body.should have_json_path("logo_url")
    response.body.should have_json_path("pitch")
    response.body.should have_json_path("website")
    response.body.should have_json_path("about")
    response.body.should have_json_path("email")
    response.body.should have_json_path("phone")
    response.body.should have_json_path("twitter_link")
    response.body.should have_json_path("facebook_link")
    response.body.should have_json_type(Array).at_path("categories")
    response.body.should have_json_type(Array).at_path("founders")
    response.body.should have_json_path("founders/0/id")
    response.body.should have_json_path("founders/0/name")
    response.body.should have_json_path("founders/0/title")
    response.body.should have_json_path("founders/0/picture_url")
    response.body.should have_json_path("founders/0/linkedin_url")
    response.body.should have_json_path("founders/0/twitter_url")

  end
end
