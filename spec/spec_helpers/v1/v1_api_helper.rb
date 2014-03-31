require_relative '../api_spec_helper'

module V1ApiSpecHelper
  include ApiSpecHelper

  def check_path(response, path)
    expect(response.body).to have_json_path(path)
  end

  def check_type(response, path, type)
    expect(response.body).to have_json_type(type).at_path(path)
  end

  def version_header(user = FactoryGirl.create(:user_with_out_password))
    {"HTTP_ACCEPT"=>'application/vnd.svapp.v1+json', 'HTTP_AUTH_TOKEN'=> user.auth_token}
  end
end
