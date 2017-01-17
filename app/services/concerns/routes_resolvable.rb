module RoutesResolvable
  extend ActiveSupport::Concern

  def url_helpers
    Rails.application.routes.url_helpers
  end
end
