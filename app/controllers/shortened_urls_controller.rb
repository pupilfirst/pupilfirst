class ShortenedUrlsController < ApplicationController
  def redirect
    shortened_url = ShortenedUrl.unexpired.find_by(unique_key: params[:unique_key])
    raise_not_found if shortened_url.blank?

    shortened_url.use
    redirect_to shortened_url.url, status: :moved_permanently
  end
end
