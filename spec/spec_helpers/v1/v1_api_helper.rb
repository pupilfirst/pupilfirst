
module V1ApiSpecHelper
  include ApiSpecHelper

  def version_header
    {"HTTP_ACCEPT"=>'application/vnd.svapp.v1+json'}
  end
end
