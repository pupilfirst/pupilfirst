class HomeController < ApplicationController
  layout 'homepage'

  def index
    @blogs = get_latest_blogs
  end

  private

  def get_latest_blogs
    Rails.cache.fetch("latest_blogs",expires_in: 24.hours) do
      wp = Rubypress::Client.new(:host => "startatsv.com",:username => ENV['WP_USERNAME'],:password => ENV['WP_PASSWORD'],:retry_timeouts => true)
      filter_hash = {orderby: "post_date",order: "DESC",post_type: "post",post_status: "publish",number: 4}
      fields_array = ["post_title","post_content","post_thumbnail","link"]
      wp.getPosts(filter: filter_hash,fields: fields_array)
    end
  end
end
