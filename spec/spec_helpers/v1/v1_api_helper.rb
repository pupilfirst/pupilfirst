
module V1ApiSpecHelper
  include ApiSpecHelper

  def check_path(response, path)
    expect(response.body).to have_json_path(path)
  end

  def check_type(response, path, type)
    expect(response.body).to have_json_type(type).at_path(path)
  end

  def version_header
    {"HTTP_ACCEPT"=>'application/vnd.svapp.v1+json', 'AUTH_TOKEN'=> (User.last or FactoryGirl.create(:employee)).auth_token}
  end
end
